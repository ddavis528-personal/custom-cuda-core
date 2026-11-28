//===-- dcu_block.cpp - the DCU model at the swap boundary ----------------===//
//
// Unpacks DCU's channels into dcu::Core's structs and packs its outputs
// back, and nothing else: the core holds every structure, timing and
// decision. Reads only DCU's own receivers and writes only its own senders
// (stub.h); the oracle is consulted for checks, never for decisions.
//
// What lives here rather than in the core: the coh_op decode, the index
// lead's check (AR 362), the testbench hooks (coverage bins, failures, the
// harness's view of dirty lines, the machine-check flag), the environment's
// knobs, and the statistics file (CCV_DCU_STATS).
//===----------------------------------------------------------------------===//
#include "stub.h"
#include "dcu_core.h"
#include "wayfold.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>

namespace ccv {
namespace skel {
namespace {

namespace D = ccv::dcu;

unsigned envU(const char *n, unsigned d) {
  const char *v = std::getenv(n);
  return v && *v ? unsigned(std::strtoul(v, nullptr, 0)) : d;
}

class DcuModel : public Stub, D::Hooks {
public:
  DcuModel(int inst, Kernel &k) : Stub(inst, k), core_(config(k), *this) {
    // A request DCU cannot take waits in its receiver: the hold TI-22 and
    // MA-12 allow (all miss buffers in use, or a line's merge list full).
    holdsBack(ch().miu_dcu);
  }
  ~DcuModel() override {
    const char *path = std::getenv("CCV_DCU_STATS");
    if (!path || !*path) return;
    FILE *f = std::fopen(path, "w");
    if (!f) return;
    const D::Core::Stats &s = core_.stats();
    std::fprintf(f, "{\n  \"kernel\": \"%s\",\n  \"cycles\": %llu,\n  \"counters\": {\n",
                 k_.name.c_str(), (unsigned long long)now_);
    const std::pair<const char *, uint64_t> c[] = {
        {"lookups", s.lookups}, {"hits", s.hits}, {"misses", s.misses}, {"merged", s.merged},
        {"bank_losers", s.losers}, {"waited", s.waited}, {"age_blocks", s.age_blocks},
        {"wp_right", s.wp_right}, {"wp_wrong", s.wp_wrong}, {"store_deferred", s.store_def},
        {"store_rdwr_cycles", s.rd_wr_cycles}, {"fill_wait", s.fill_wait}, {"fills", s.fills},
        {"evicts", s.evicts}, {"notices", s.notices}, {"held_cycles", s.held_cycles},
        {"rsp_credit_wait", s.rsp_credit_wait}, {"at_qdepth", s.at_qdepth},
        {"at_stdata", s.at_stdata}, {"idle", s.idle}};
    for (size_t i = 0; i != sizeof c / sizeof *c; ++i)
      std::fprintf(f, "    \"%s\": %llu%s\n", c[i].first, (unsigned long long)c[i].second,
                   i + 1 == sizeof c / sizeof *c ? "" : ",");
    std::fprintf(f, "  }\n}\n");
    std::fclose(f);
  }
  const char *kind() const override { return "dcu"; }

private:
  D::Core core_;

  static D::Config config(const Kernel &k) {
    D::Config c;
    c.sets = envU("CCV_DCU_SETS", c.sets);
    if (!c.sets || (c.sets & (c.sets - 1))) c.sets = ccv::prov::kDcuSets;
    c.ways = envU("CCV_DCU_WAYS", c.ways);
    if (!c.ways || c.ways > 16) c.ways = ccv::prov::kDcuWays;
    c.age = envU("CCV_DCU_BANK_AGE", c.age);
    // 8 in the hosts until TI moves dcu-wb-refetch under the knob (DI-38,
    // TI-530 (2)): with the ack taking effect at once the refetch window
    // closes and the control goes unnoticed; 0 is the RTL's timing.
    c.wb_ack_delay = envU("CCV_DCU_WB_ACK_DELAY", 8);
    c.victim_at = envU("CCV_DCU_VICTIM_AT", c.victim_at);
    c.qdepth = envU("CCV_DCU_BANK_QDEPTH", c.qdepth);
    c.stdata = envU("CCV_DCU_BANK_STDATA", c.stdata);
    c.wp_bits = envU("CCV_DCU_WAYPRED_BITS", c.wp_bits);
    if (const char *v = std::getenv("CCV_DCU_WAYPRED_SEL")) {
      c.wp_recent = std::string(v) != "index" && std::string(v) != "0";
      c.wp_mru = std::string(v) == "mru";
    }
    c.gap = envU("CCV_DCU_STORE_GAP", c.gap);
    c.hash = envU("CCV_DCU_BANK_HASH", 0) != 0;
    c.ue_every = envU("CCV_DCU_UE_INJECT", 0);
    c.ue_track = envU("CCV_DCU_UE_TRACK", c.ue_track);
    c.ecc_every = envU("CCV_DCU_ECC_INJECT", 0);
    c.notice = envU("CCV_DCU_NOTICE", c.notice) != 0;
    // Under MI's MIU model, MIU's A2 drops every other slot on a bank
    // (MA-27), so two lookups due in one bank in one cycle never happen
    // (DI-25 (4), MA rev 156). The stub sends them; the loser path stays.
    if (const char *v = std::getenv("CCV_MIU_IMPL")) c.no_cycle_conflict = std::string(v) == "model";
    c.brk = k.brk;
    return c;
  }

  // ---- hooks ------------------------------------------------------------------
  void fail(const std::string &m) override { k_.fail("%s", m.c_str()); }
  void hit(const char *bin, uint64_t n) override { k_.hit(bin, n); }
  void peak(const char *bin, uint64_t v) override { k_.peak(bin, v); }
  void dirty(uint64_t line, const D::Line &l) override {
    k_.dcu_dirty[line].assign(l.begin(), l.end());
  }
  void clean(uint64_t line) override { k_.dcu_dirty.erase(line); }
  void fatal() override { k_.mce_raised = true; }
  void withheld(unsigned id) override { k_.ue_withheld.insert(id); }

  /// AR 362: the lead's set index is a copy of the lookup's phys_addr bits,
  /// and DCU refuses one that differs, by name (--break dcu-set-lead).
  void checkIndexLead(unsigned s, const Bits &req) {
    const Ch &c = ch();
    const uint64_t pa = get(req, c.miu_dcu, "phys_addr");
    const uint64_t set = (pa >> 7) & ((uint64_t(1) << ccv::prov::kWDcuSet) - 1);
    const uint64_t ls = get(req, c.miu_dcu, "lead_set_index");
    if (ls != set)
      k_.fail("dcu: slot %u req_id %u lead_set_index %llx is not its phys_addr %llx's set %llx",
              s, unsigned(get(req, c.miu_dcu, "req_id")), (unsigned long long)ls,
              (unsigned long long)pa, (unsigned long long)set);
    // TI-518, AR 405 (3): MIU's pa_fold is DCU's own fold of phys_addr
    // whenever the predictor is on (--break miu-fold-flip), as the stub's.
    const unsigned k = core_.config().wp_bits;
    const uint64_t pf = get(req, c.miu_dcu, "pa_fold");
    const unsigned sb = ccv::skel::wayFoldSetBits(core_.config().sets);
    if (k && !core_.config().wp_mru && pf != ccv::skel::wayFold(pa, k, sb))
      k_.fail("dcu: slot %u req_id %u pa_fold %llx is not its phys_addr %llx's fold %x",
              s, unsigned(get(req, c.miu_dcu, "req_id")), (unsigned long long)pf,
              (unsigned long long)pa, ccv::skel::wayFold(pa, k, sb));
  }

  D::Req decode(unsigned s, const Receiver::Msg &m) {
    const Ch &c = ch();
    D::Req r;
    r.slot = s;
    r.req_id = unsigned(get(m.payload, c.miu_dcu, "req_id"));
    r.pa = get(m.payload, c.miu_dcu, "phys_addr");
    const unsigned co = unsigned(get(m.payload, c.miu_dcu, "coh_op"));
    r.op = co == kCohRead ? D::Op::Read : co == kCohAcquireData ? D::Op::AtomRead : D::Op::Store;
    if (r.op == D::Op::Store) {
      const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
      for (unsigned k = 0; k != kLine; ++k) r.mask[k] = m.payload.bit(mlsb + k);
      r.wdata = getLine(m.payload, field(c.miu_dcu, "write_data").lsb);
    }
    r.tid = m.tid;
    return r;
  }

  void work() override {
    const Ch &c = ch();
    // Slice 2, part 1: a fill's ccv_mlc_dcu_rsp credit is its fill buffer,
    // home when the line is written and its last answer has left (an
    // acknowledgement's at once).
    if (!armed_) {
      armed_ = true;
      creditAtRelease(c.mlc_dcu);
    }
    std::vector<D::Req> in;
    // Requests whose payload lands now, in slot order, unless DCU holds the
    // channel; a held one is taken the first cycle DCU accepts again. One a
    // slot a cycle: a receiver returns one credit per pop a cycle, so two
    // pops in a cycle lose one (channel.h, Receiver::pop).
    if (core_.accepting())
      for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s)
        if (has(c.miu_dcu, s)) {
          Receiver::Msg m = take(c.miu_dcu, s);
          if (get(m.payload, c.miu_dcu, "drop")) {
            // A dropped lookup (MA-27, AR 400, AR 404): DCU reads nothing,
            // changes nothing, queues nothing, raises no CE, UE or core-fatal
            // and answers nothing; MIU refunds its entry credit itself
            // (DI-12). Controls: dcu-drop-answers serves it as a lookup, and
            // dcu-drop-credit returns an entry credit for it, which MIU must
            // refuse past its reset count.
            k_.hit("dcu_drop");
            if (k_.brk == "dcu-drop-credit")
              ++cred_ent_[core_.bankOf(get(m.payload, c.miu_dcu, "phys_addr"))];
            if (k_.brk != "dcu-drop-answers") continue;
          }
          checkIndexLead(s, m.payload);
          in.push_back(decode(s, m));
        }
    std::optional<D::Fill> fill;
    if (has(c.mlc_dcu, 0)) {
      Receiver::Msg m = take(c.mlc_dcu, 0);
      D::Fill f;
      f.id = unsigned(get(m.payload, c.mlc_dcu, "req_id"));
      f.line = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
      f.miss = get(m.payload, c.mlc_dcu, "miss") != 0;
      f.own = get(m.payload, c.mlc_dcu, "ownership") != 0;
      fill = f;
    }
    // Slice 2, part 4: an inbound probe (MLC's own req_id: its probe buffer).
    std::optional<D::Probe> prb;
    if (has(prb_in_, 0)) {
      Receiver::Msg m = take(prb_in_, 0);
      D::Probe q;
      q.id = unsigned(get(m.payload, prb_in_, "req_id"));
      q.pa = get(m.payload, prb_in_, "phys_addr");
      q.inval = get(m.payload, prb_in_, "invalidate_or_downgrade") != 0;
      prb = q;
    }
    D::Ports p;
    for (unsigned s = 0; s != D::kSlots; ++s) {
      p.rsp_can[s] = can(c.dcu_miu, s);
      p.rsp_credits[s] = credits(c.dcu_miu, s);
      p.ntc_can[s] = can(c.fill_ntc, s);
    }
    p.mlc_can = can(c.dcu_mlc, 0);
    p.prb_can = can(prb_ack_, 0);
    const D::Out o = core_.cycle(now_, in, fill, p, prb);
    if (o.prb_ack) {
      Bits b = msgOf(prb_ack_);
      put(b, prb_ack_, "req_id", o.prb_ack->id);
      put(b, prb_ack_, "ack", o.prb_ack->data);
      if (o.prb_ack->data) putLine(b, field(prb_ack_, "dirty_data").lsb, o.prb_ack->line);
      send(prb_ack_, 0, b, makeUid(IdClass::kNone, 0));
    }
    for (unsigned k = 0; k != o.fill_release; ++k) release(c.mlc_dcu, 0);
    for (const auto &n : o.notices) {
      Bits b = msgOf(c.fill_ntc);
      put(b, c.fill_ntc, "req_id", n.req_id);
      send(c.fill_ntc, n.slot, b, n.tid);
    }
    for (const D::Rsp &r : o.rsps) {
      Bits b = msgOf(c.dcu_miu);
      put(b, c.dcu_miu, "req_id", r.req_id);
      if (r.data) putLine(b, field(c.dcu_miu, "read_data").lsb, r.line);
      // MA-28 (c), AR 401: the stored check bits of the line as written, and
      // the stored bit in error the core's arrays hold (CCV_DCU_ECC_INJECT)
      // flipped under them, as the data array reads it. dcu-ecc-recode, the
      // control, codes the bad line instead, so MIU's syndrome misses it.
      Line ln = getLine(b, field(c.dcu_miu, "read_data").lsb);
      if (r.flip >= 0) ln[unsigned(r.flip) / 8] ^= uint8_t(1u << (r.flip % 8));
      if (r.flip2 >= 0) ln[unsigned(r.flip2) / 8] ^= uint8_t(1u << (r.flip2 % 8));
      putCheckBits(b, field(c.dcu_miu, "check_bits").lsb,
                   k_.brk == "dcu-ecc-recode" ? ln : getLine(b, field(c.dcu_miu, "read_data").lsb));
      putLine(b, field(c.dcu_miu, "read_data").lsb, ln);
      put(b, c.dcu_miu, "hit", r.hit);
      put(b, c.dcu_miu, "mlc_miss", r.mlc_miss);
      send(c.dcu_miu, r.slot, b, r.tid);
    }
    if (o.mlc) {
      Bits b = msgOf(c.dcu_mlc);
      put(b, c.dcu_mlc, "phys_addr", o.mlc->pa);
      const unsigned co = o.mlc->op == D::MlcOp::Read ? kCohRead
                          : o.mlc->op == D::MlcOp::Write ? kCohWrite
                          : o.mlc->op == D::MlcOp::AcquireData ? kCohAcquireData
                                                               : kCohAcquirePerm;
      put(b, c.dcu_mlc, "coh_op", co);
      put(b, c.dcu_mlc, "req_id", o.mlc->id);
      if (o.mlc->data) putLine(b, field(c.dcu_mlc, "writeback_data").lsb, o.mlc->line);
      send(c.dcu_mlc, 0, b,
           o.mlc->tid ? o.mlc->tid : makeUid(IdClass::kTxn, g_unowned_txn++));
    }
    // MA-25's credit returns on ccv_dcu_miu_cred (TI, landing the channel):
    // the core's two vectors, kept a count a bank while the channel cannot
    // take them, so a return is never lost (OI-18 rule: DI owns this file).
    for (unsigned b = 0; b != ccv::kDcuBanks; ++b) {
      cred_ent_[b] += o.ent_ret >> b & 1u;
      cred_std_[b] += o.std_ret >> b & 1u;
    }
    {
      uint64_t ent = 0, std = 0;
      for (unsigned b = 0; b != ccv::kDcuBanks; ++b) {
        if (cred_ent_[b]) ent |= uint64_t(1) << b;
        if (cred_std_[b]) std |= uint64_t(1) << b;
      }
      // --break dcu-extra-credit: an entry credit on bank 0 that MIU never
      // spent, at the first chance, which MIU must refuse by name (MA-25).
      const bool extra = k_.brk == "dcu-extra-credit" && !extra_sent_;
      if (extra) ent |= 1;
      if ((ent || std) && can(c.dcu_cred, 0)) {
        Bits b = msgOf(c.dcu_cred);
        put(b, c.dcu_cred, "ent_ret", ent);
        put(b, c.dcu_cred, "std_ret", std);
        send(c.dcu_cred, 0, b, makeUid(IdClass::kNone, 0));
        for (unsigned k = 0; k != ccv::kDcuBanks; ++k) {
          if (cred_ent_[k]) --cred_ent_[k];
          if (cred_std_[k]) --cred_std_[k];
        }
        if (extra) extra_sent_ = true;
      }
    }
    if (o.ue_raise || ue_owed_) {
      ue_owed_ = true;
      if (can(c.dcu_cru_err, 0)) {
        Bits e = msgOf(c.dcu_cru_err);
        put(e, c.dcu_cru_err, "ue", 1);
        put(e, c.dcu_cru_err, "ce_alert", 0);
        send(c.dcu_cru_err, 0, e, makeUid(IdClass::kNone, 0));
        ue_owed_ = false;
      }
    }
  }
  bool ue_owed_ = false;
  bool armed_ = false;
  // The probe channels, which stub.h's Ch does not name yet.
  const unsigned prb_in_ = chanId("ccv_mlc_dcu_probe");
  const unsigned prb_ack_ = chanId("ccv_dcu_mlc_probe_ack");
  bool extra_sent_ = false;
  std::array<unsigned, ccv::kDcuBanks> cred_ent_{}, cred_std_{};
  bool credOwed() const {
    for (unsigned b = 0; b != ccv::kDcuBanks; ++b)
      if (cred_ent_[b] || cred_std_[b]) return true;
    return false;
  }
  bool busy() const override { return core_.busy() || ue_owed_ || credOwed(); }
};

} // namespace

/// The DCU model (sim/dcu/), behind TI's makeDcu hook (DI-1).
std::unique_ptr<Block> makeDcuModel(int inst, Kernel &k) { return std::make_unique<DcuModel>(inst, k); }

} // namespace skel
} // namespace ccv
