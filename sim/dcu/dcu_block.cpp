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
    c.qdepth = envU("CCV_DCU_BANK_QDEPTH", c.qdepth);
    c.stdata = envU("CCV_DCU_BANK_STDATA", c.stdata);
    c.wp_bits = envU("CCV_DCU_WAYPRED_BITS", c.wp_bits);
    if (const char *v = std::getenv("CCV_DCU_WAYPRED_SEL"))
      c.wp_recent = std::string(v) != "index" && std::string(v) != "0";
    c.gap = envU("CCV_DCU_STORE_GAP", c.gap);
    c.hash = envU("CCV_DCU_BANK_HASH", 0) != 0;
    c.ue_every = envU("CCV_DCU_UE_INJECT", 0);
    c.ue_track = envU("CCV_DCU_UE_TRACK", c.ue_track);
    c.notice = envU("CCV_DCU_NOTICE", 1) != 0;
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
    std::vector<D::Req> in;
    // Requests whose payload lands now, in slot order, unless DCU holds the
    // channel; a held one is taken the first cycle DCU accepts again. One a
    // slot a cycle: a receiver returns one credit per pop a cycle, so two
    // pops in a cycle lose one (channel.h, Receiver::pop).
    if (core_.accepting())
      for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s)
        if (has(c.miu_dcu, s)) {
          Receiver::Msg m = take(c.miu_dcu, s);
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
    D::Ports p;
    for (unsigned s = 0; s != D::kSlots; ++s) {
      p.rsp_can[s] = can(c.dcu_miu, s);
      p.rsp_credits[s] = credits(c.dcu_miu, s);
      p.ntc_can[s] = can(c.fill_ntc, s);
    }
    p.mlc_can = can(c.dcu_mlc, 0);
    const D::Out o = core_.cycle(now_, in, fill, p);
    for (const auto &n : o.notices) {
      Bits b = msgOf(c.fill_ntc);
      put(b, c.fill_ntc, "req_id", n.req_id);
      send(c.fill_ntc, n.slot, b, n.tid);
    }
    for (const D::Rsp &r : o.rsps) {
      Bits b = msgOf(c.dcu_miu);
      put(b, c.dcu_miu, "req_id", r.req_id);
      if (r.data) putLine(b, field(c.dcu_miu, "read_data").lsb, r.line);
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
  bool busy() const override { return core_.busy() || ue_owed_; }
};

} // namespace

/// The DCU model (sim/dcu/), behind TI's makeDcu hook (DI-1).
std::unique_ptr<Block> makeDcuModel(int inst, Kernel &k) { return std::make_unique<DcuModel>(inst, k); }

} // namespace skel
} // namespace ccv
