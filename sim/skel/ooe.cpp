//===-- ooe.cpp - OOE behind the swap boundary ------------------------===//
//
// The S1 OOE stub: in-order issue with a scoreboard, in-order retire, a real
// GPR RAT and free list, the copy-only op, checkpoint release and the fetch
// epoch. Its contract is the schema (ccv_*_uop, _issue, _memop, _redirect,
// _ckpt_free, ...) and the OOE microarchitecture doc; docs/ooe-4b.md is the
// handoff for the Stage 4b model that replaces it.
//===----------------------------------------------------------------------===//
#include "stub.h"

#include <cstdlib>

namespace ccv {
namespace skel {
namespace {

// ---- OOE: in-order issue with a scoreboard, in-order retire ------------------------

class Ooe : public Stub {
public:
  Ooe(int inst, Kernel &k) : Stub(inst, k) {
    for (auto &w : rat_) w.fill(ccv::prov::kPhysZero);
    for (unsigned p = 0; p != ccv::prov::kPhysRegs; ++p) free_.push_back(p);
    k.rat0.assign(kArchGprs, ccv::prov::kPhysZero);
  }
  const char *kind() const override { return "ooe"; }

private:
  struct E {
    uint64_t tid, pc;
    unsigned tag, warp;
    const OpInfo *op;
    unsigned src[3], dst, pguard, pdst;   ///< architectural
    uint32_t imm = 0;
    unsigned ilen = 0;                     ///< length code: 0/1/2 = 2/4/6 bytes
    bool scale_en = false, pneg = false, pwe = false;
    bool taken = false, pred_taken = false;
    uint32_t taken_mask = 0;
    unsigned ckpt = 0;                     ///< FET's checkpoint, on a branch
    uint32_t mask = 0;                     ///< the PC group's lanes, from FET (A-69)
    uint32_t attr = 0;                     ///< sched_attr, from DEC (A-66)
    unsigned mem_op = 0, space = 0, ordering = 0;   ///< DEC's, passed to MIU (A-68)
    // Physical names, read from the RAT at dispatch: a register no older
    // instruction of the warp has written is still the zero register (A-64).
    unsigned psrc[3] = {}, pold = 0, pnew = 0, ppguard = 0, ppold = 0;
    bool issued = false, rcu = false, miu = false, committed = false;
    // A masked load's copy-only op (A-38) sends no done: OOE clears this at
    // the copy's contracted wake, issue + CCV_LAT_LANE, as for a lane op.
    bool copy_pending = false;
    uint64_t copy_wake = 0;
    bool complete() const {
      return op->cls == kExit ? issued
                              : issued && rcu && (!attrMem(attr) || miu) && !copy_pending;
    }
  };
  std::deque<E> rob_;
  unsigned next_tag_ = 0;
  // Identity, shadowed from RAU's table on every activation (Q-38), and the
  // tier-1 slot RAU placed each warp in (A-65).
  uint32_t ctaid_[32] = {}, warp_in_cta_[32] = {};
  unsigned slot_[32] = {};
  // The GPR RAT: every write takes a fresh physical register from the free
  // list, and the one it replaces goes back when the writer retires -- no
  // older instruction can still read it then, and every younger one reads
  // the new name. A register no instruction of the warp has written maps to
  // the zero register (A-64). The free list is FIFO, so a freed register
  // comes back with a stale value; that is what makes a merge or a masked
  // load's copy that read the wrong source visible.
  //
  // Predicates are not renamed: each warp keeps a fixed window, and pw_
  // records only whether one has been written since launch (A-64).
  std::array<std::array<unsigned, 16>, 32> rat_;
  std::deque<unsigned> free_;
  std::set<unsigned> used_;     ///< registers ever allocated (coverage)
  bool pw_[32][4] = {};
  static constexpr unsigned kRob = 128;

  void work() override {
    const Ch &c = ch();
    if (has(c.rau_ooe, 0)) {
      Receiver::Msg m = take(c.rau_ooe, 0);
      const unsigned w = unsigned(get(m.payload, c.rau_ooe, "warp_id"));
      const unsigned op = unsigned(get(m.payload, c.rau_ooe, "alloc_op"));
      slot_[w] = unsigned(get(m.payload, c.rau_ooe, "tier1_id"));
      ctaid_[w] = uint32_t(get(m.payload, c.rau_ooe, "ctaid"));
      warp_in_cta_[w] = uint32_t(get(m.payload, c.rau_ooe, "warp_in_cta"));
      if (op == kAllocLaunch) {
        // Launch (A-64): every architectural register maps to the zero
        // registers until written. No zeroing traffic, and nothing stale
        // from another context can be read.
        for (unsigned &p : rat_[w]) {
          if (p != ccv::prov::kPhysZero) free_.push_back(p);
          p = ccv::prov::kPhysZero;
        }
        for (bool &b : pw_[w]) b = false;
        // The epoch is not reset: a relaunched warp_id could otherwise meet
        // its predecessor's uops still in flight at the same epoch (A-74).
        if (w == 0) k_.rat0.assign(kArchGprs, ccv::prov::kPhysZero);
      } else if (op != kAllocFree) {
        k_.fail("ooe: restore (alloc_op %u) is not modelled in S1", op);
      }
    }
    // Uops: oldest first by (arrival, slot) -- all landed this cycle, so slot
    // order is age order; the key (warp_id) keeps each warp's own order.
    // A uop waits in the channel -- its credit unreturned -- while the ROB
    // is full or no physical register is free: rename stalls, never drops.
    for (unsigned s = 0; s != kChans[c.dec_ooe].rate; ++s)
      while (has(c.dec_ooe, s) && rob_.size() != kRob && !free_.empty())
        dispatch(take(c.dec_ooe, s));
    for (unsigned s = 0; s != kChans[c.rcu_ooe].rate; ++s)
      while (has(c.rcu_ooe, s)) {
        Receiver::Msg m = take(c.rcu_ooe, s);
        if (E *e = byTag(unsigned(get(m.payload, c.rcu_ooe, "rob_tag")))) {
          e->rcu = true;
          e->taken = get(m.payload, c.rcu_ooe, "branch_taken") != 0;
          e->taken_mask = uint32_t(get(m.payload, c.rcu_ooe, "branch_mask"));
          // A mispredict is the resolved outcome against FET's prediction
          // (A-42); only then does OOE redirect, naming the checkpoint. A
          // correct resolution frees the checkpoint instead, on the bitmap
          // (A-56); a mispredict's is FET's to free, on the redirect.
          if (attrBranch(e->attr)) {
            if (e->taken != e->pred_taken) {
              redirect(*e);
              // stale-free breaks A-58's first rule on purpose: it frees the
              // checkpoint the same cycle's redirect restores.
              if (k_.brk == "stale-free") free_mask_ |= freeBit(*e);
            } else {
              free_mask_ |= freeBit(*e);
            }
          }
        } else {
          k_.fail("ooe: done for a tag not in the ROB");
        }
      }
    for (unsigned s = 0; s != kChans[c.miu_ooe].rate; ++s)
      while (has(c.miu_ooe, s)) {
        Receiver::Msg m = take(c.miu_ooe, s);
        if (get(m.payload, c.miu_ooe, "status") != 0) k_.fail("ooe: memory op failed");
        if (E *e = byTag(unsigned(get(m.payload, c.miu_ooe, "rob_tag")))) e->miu = true;
        else k_.fail("ooe: completion for a tag not in the ROB");
      }
    for (E &e : rob_)
      if (e.copy_pending && now_ >= e.copy_wake) e.copy_pending = false;
    issueOne();
    retireOne();
    if (!redirects_.empty() && can(c.ooe_fet, 0)) {
      send(c.ooe_fet, 0, redirects_.front().msg, redirects_.front().tid);
      redirects_.pop_front();
    }
    // Every checkpoint freed this cycle, in one message. The channel is
    // fixed-latency, so a credit is always back in time; if one were not, the
    // bits would simply ride the next message.
    if (free_mask_ && can(c.ooe_free, 0)) {
      Bits f = msgOf(c.ooe_free);
      put(f, c.ooe_free, "free_mask", free_mask_);
      send(c.ooe_free, 0, f, makeUid(IdClass::kNone, 0));
      free_mask_ = 0;
    }
  }

  /// Bit tier1_id * CCV_P_BR_CKPTS + checkpoint_id, the slot from RAU (A-65).
  uint64_t free_mask_ = 0;
  uint64_t freeBit(const E &e) const { return uint64_t(1) << (slot_[e.warp] * kCkpts + e.ckpt); }

  /// RCU resolved a branch some lane takes: tell FET, which owns the PC.
  /// Group masks: the taken lanes, then the lanes that fall through.
  unsigned epoch_[32] = {};     ///< each warp's current fetch epoch (A-70)
  std::deque<Q> redirects_;
  static constexpr unsigned kCkpts = ccv::prov::kBrCkpts;
  void redirect(const E &e) {
    const Ch &c = ch();
    Bits r = msgOf(c.ooe_fet);
    put(r, c.ooe_fet, "warp_id", e.warp);
    put(r, c.ooe_fet, "tier1_id", slot_[e.warp]);
    // imm is the architectural offset, in halfwords from the NEXT
    // instruction; ilen says how long this one is (arch open A-8).
    put(r, c.ooe_fet, "target_pc",
        e.pc + 2 * (e.ilen + 1) + uint64_t(2 * int64_t(int32_t(e.imm))));
    // FET rebuilds the PC groups from its own checkpoint and the lanes
    // that took the branch; OOE resends no group state.
    put(r, c.ooe_fet, "checkpoint_id",
        k_.brk == "corrupt-ckpt" ? (e.ckpt + 1) % kCkpts : e.ckpt);
    put(r, c.ooe_fet, "taken_mask", e.taken_mask);
    // The warp's epoch advances, and the redirect carries the new one: FET
    // tags what it fetches from here on with it (A-70).
    epoch_[e.warp] = (epoch_[e.warp] + 1) % (1u << field(c.ooe_fet, "fetch_epoch").width);
    put(r, c.ooe_fet, "fetch_epoch", epoch_[e.warp]);
    // A real redirect. OOE also sends epoch_only notices on this channel for
    // a demotion or kill (A-74); the stubs model neither yet.
    put(r, c.ooe_fet, "epoch_only", 0);
    redirects_.push_back({0, r, e.tid});
    k_.hit("redirect");
  }

  E *byTag(unsigned t) {
    for (E &e : rob_) if (e.tag == t) return &e;
    return nullptr;
  }

  void dispatch(const Receiver::Msg &m) {
    const Ch &c = ch();
    const Bits &u = m.payload;
    E e;
    e.tid = m.tid;
    e.pc = get(u, c.dec_ooe, "pc");
    e.warp = unsigned(get(u, c.dec_ooe, "warp_id"));
    // A uop fetched before the warp's last redirect is wrong-path: it is
    // dropped here, before rename, by its epoch (A-70).
    if (unsigned(get(u, c.dec_ooe, "fetch_epoch")) != epoch_[e.warp]) {
      k_.hit("epoch_drop");
      return;
    }
    e.mask = uint32_t(get(u, c.dec_ooe, "group_mask"));
    e.op = opByCode(unsigned(get(u, c.dec_ooe, "opcode")));
    if (!e.op || get(u, c.dec_ooe, "decode_fault")) {
      k_.fail("ooe: a uop it cannot execute");
      return;
    }
    const unsigned sa = unsigned(get(u, c.dec_ooe, "src_arch"));
    e.src[0] = (sa >> 4) & 15;
    e.src[1] = sa & 15;
    e.src[2] = unsigned(get(u, c.dec_ooe, "src2_arch"));
    e.dst = unsigned(get(u, c.dec_ooe, "dst_arch"));
    e.imm = uint32_t(get(u, c.dec_ooe, "imm"));
    e.ilen = unsigned(get(u, c.dec_ooe, "ilen"));
    e.scale_en = get(u, c.dec_ooe, "scale_en") != 0;
    e.pneg = get(u, c.dec_ooe, "pred_neg") != 0;
    e.pguard = unsigned(get(u, c.dec_ooe, "pred_guard"));
    e.pdst = unsigned(get(u, c.dec_ooe, "pred_dst"));
    e.pwe = get(u, c.dec_ooe, "pred_we") != 0;
    e.ckpt = unsigned(get(u, c.dec_ooe, "checkpoint_id"));
    e.pred_taken = get(u, c.dec_ooe, "pred_taken") != 0;
    e.attr = uint32_t(get(u, c.dec_ooe, "sched_attr"));
    e.mem_op = unsigned(get(u, c.dec_ooe, "mem_op"));
    e.space = unsigned(get(u, c.dec_ooe, "space"));
    e.ordering = unsigned(get(u, c.dec_ooe, "ordering"));
    // Rename: sources and old destinations read the RAT before this
    // instruction's own writes update it (A-64).
    auto q = [&](unsigned a) { return pw_[e.warp][a & 3] ? physPred(e.warp, a) : ccv::prov::kPredZero; };
    for (unsigned i = 0; i != 3; ++i) e.psrc[i] = rat_[e.warp][e.src[i] & 15];
    e.pold = rat_[e.warp][e.dst & 15];
    e.ppguard = q(e.pguard);
    e.ppold = q(e.pdst);
    if (e.op->gdst) {
      e.pnew = free_.front();
      free_.pop_front();
      if (!used_.insert(e.pnew).second) k_.hit("reg_reuse");   // came back from a retire
      rat_[e.warp][e.dst & 15] = e.pnew;
      if (e.warp == 0) k_.rat0[e.dst & 15] = e.pnew;   // the final compare's map
    }
    if (e.pwe) pw_[e.warp][e.pdst & 3] = true;
    e.tag = next_tag_;
    next_tag_ = (next_tag_ + 1) % kRob;
    emit(now_, e.tid, EV_DISPATCH, UNIT_OOE, e.warp, e.tag);
    rob_.push_back(e);
  }

  /// Registers an entry reads and writes, as (kind, index) pairs.
  static void regs(const E &e, std::vector<unsigned> &rd, std::vector<unsigned> &wr) {
    for (unsigned i = 0; i != e.op->nsrc; ++i) rd.push_back(e.src[i]);
    if (e.op->guard || e.op->pdata) rd.push_back(100 + e.pguard);
    if (e.op->cls == kPredLogic) {    // its sources are qualifiers in imm
      rd.push_back(100 + (e.imm & 3));
      rd.push_back(100 + ((e.imm >> 3) & 3));
    }
    if (e.op->gdst) wr.push_back(e.dst);
    if (e.pwe) wr.push_back(100 + e.pdst);
  }

  void issueOne() {
    const Ch &c = ch();
    size_t i = 0;
    while (i != rob_.size() && rob_[i].issued) ++i;
    if (i == rob_.size()) return;
    E &e = rob_[i];
    std::vector<unsigned> rd, wr;
    regs(e, rd, wr);
    const bool mem = attrMem(e.attr);
    for (size_t j = 0; j != i; ++j) {
      if (rob_[j].complete()) continue;
      std::vector<unsigned> ord, owr;
      regs(rob_[j], ord, owr);
      for (unsigned w : owr) {
        for (unsigned r : rd) if (r == w) return;    // RAW
        for (unsigned x : wr) if (x == w) return;    // WAW
      }
      const bool omem = attrMem(rob_[j].attr);
      if (mem && omem) return;                       // memory in order
      if (e.op->cls == kExit) return;                // exit waits for all
    }
    if (e.op->cls == kExit) { e.issued = true; return; }
    const unsigned slot = e.tag % kChans[c.ooe_rcu].rate;
    // Merge (A-33): some lane may keep its old value -- the issue mask is
    // not full, or a guard may switch lanes off -- so the old destination is
    // a fourth source: the RAT's old mapping, the zero register if unwritten.
    // The issue group is the PC group the uop arrived with (A-69), and a
    // mask that is not full means some lane keeps its old value.
    const uint32_t issue_mask = e.mask;
    const bool merge = issue_mask != 0xffffffffu || e.op->guard;
    // A masked load owes a copy-only op beside it (A-33, A-38): MIU writes
    // only its active lanes, so the inactive ones are copied from the old
    // destination through a lane, on a second issue slot the same cycle.
    const bool copy = merge && mem && attrMemKind(e.attr) == kMemKLoad;
    const unsigned cslot = (slot + 1) % kChans[c.ooe_rcu].rate;
    if (!can(c.ooe_rcu, slot) || (mem && !can(c.ooe_miu, slot)) ||
        (copy && !can(c.ooe_rcu, cslot)))
      return;
    Bits is = msgOf(c.ooe_rcu);
    put(is, c.ooe_rcu, "rob_tag", e.tag);
    put(is, c.ooe_rcu, "warp_id", e.warp);
    put(is, c.ooe_rcu, "issue_mask", issue_mask);
    put(is, c.ooe_rcu, "phys_src", (e.psrc[0] << 8) | e.psrc[1]);
    put(is, c.ooe_rcu, "phys_src2", e.psrc[2]);
    // srd's value is identity, which OOE holds, so it goes in the immediate
    // here and RCU substitutes it like any other: warp_base for %ctatid
    // (the lane ORs its index in), %ctaid itself for selector 1.
    uint32_t imm = e.imm;
    if (e.op->srd_sel >= 0)
      imm = e.op->or_lane ? warp_in_cta_[e.warp] << 5 : ctaid_[e.warp];
    if (!mem) put(is, c.ooe_rcu, "imm", imm);
    put(is, c.ooe_rcu, "phys_dst", e.op->gdst ? e.pnew : 0);
    put(is, c.ooe_rcu, "phys_pred_guard", e.ppguard);
    put(is, c.ooe_rcu, "phys_pred_dst", physPred(e.warp, e.pdst));
    put(is, c.ooe_rcu, "pred_we", e.pwe);
    put(is, c.ooe_rcu, "merge_en", merge);
    if (merge) k_.hit("merge");
    for (unsigned i = 0; i != e.op->nsrc; ++i)
      if (e.psrc[i] == ccv::prov::kPhysZero) k_.hit("zero_read");
    if (merge && e.op->gdst && e.pold == ccv::prov::kPhysZero) k_.hit("zero_read");
    put(is, c.ooe_rcu, "phys_old_dst", merge ? e.pold : 0);
    put(is, c.ooe_rcu, "phys_pred_old_dst", merge ? e.ppold : 0);
    // corrupt-ckpt and stale-free ride drop-negate's forced mispredict: each
    // needs a redirect.
    put(is, c.ooe_rcu, "pred_neg", e.pneg && k_.brk != "drop-negate" &&
                                   k_.brk != "corrupt-ckpt" && k_.brk != "stale-free");
    put(is, c.ooe_rcu, "opcode", opcodeOf(e.op));
    send(c.ooe_rcu, slot, is, e.tid);
    if (copy) {
      // The same issue as the load's -- tag, destination, old destination,
      // guard -- under CCV_OP_PRF_COPY. An unguarded load masked only by
      // its issue mask would name the zero predicate negated: all ones.
      Bits cp = is;
      put(cp, c.ooe_rcu, "opcode", kOpCopy);
      if (!e.op->guard) {
        put(cp, c.ooe_rcu, "phys_pred_guard", ccv::prov::kPredZero);
        put(cp, c.ooe_rcu, "pred_neg", 1);
      }
      // skip-copy: OOE issues the load alone, so the inactive lanes keep
      // whatever the fresh register held.
      if (k_.brk != "skip-copy") send(c.ooe_rcu, cslot, cp, e.tid);
      k_.hit("copy");
      e.copy_pending = true;
      e.copy_wake = now_ + ccv::prov::kLatLane;
    }
    if (mem) {
      Bits mo = msgOf(c.ooe_miu);
      put(mo, c.ooe_miu, "rob_tag", e.tag);
      put(mo, c.ooe_miu, "warp_id", e.warp);
      put(mo, c.ooe_miu, "mem_op", e.mem_op);             // DEC's, unexamined (A-68)
      // The issue mask, not the active mask: only RCU holds the predicate
      // values, so only RCU computes active = issue AND guard.
      put(mo, c.ooe_miu, "issue_mask", issue_mask);
      // Write-back destinations, for MIU to echo: RCU keeps no load table.
      put(mo, c.ooe_miu, "phys_dst", e.pnew);
      put(mo, c.ooe_miu, "phys_pred", physPred(e.warp, e.pdst));
      put(mo, c.ooe_miu, "disp",                    // truncated to CCV_W_DISP
          e.imm + (k_.brk == "corrupt-disp" && uidSeq(e.tid) == 6 ? 4u : 0u));
      put(mo, c.ooe_miu, "scale_en", e.scale_en);
      put(mo, c.ooe_miu, "space", e.space);
      put(mo, c.ooe_miu, "ordering", e.ordering);
      send(c.ooe_miu, slot, mo, e.tid);
    }
    e.issued = true;
    emit(now_, e.tid, EV_ISSUE, UNIT_OOE, e.warp, slot, e.tag);
  }

  void retireOne() {
    const Ch &c = ch();
    if (rob_.empty() || !rob_.front().complete()) return;
    E &e = rob_.front();
    if (attrMem(e.attr) && attrMemKind(e.attr) == kMemKStore && !e.committed) {
      const unsigned slot = e.tag % kChans[c.ooe_ret].rate;
      if (!can(c.ooe_ret, slot)) return;
      Bits r = msgOf(c.ooe_ret);
      put(r, c.ooe_ret, "rob_tag", e.tag);
      put(r, c.ooe_ret, "commit_or_discard", 1);
      send(c.ooe_ret, slot, r, e.tid);
      e.committed = true;
    }
    // No active-lane mask reaches OOE: active_mask is RCU's alone (Q-23),
    // so every group retires with all 32 lanes.
    emit(now_, e.tid, EV_RETIRE, UNIT_OOE, e.warp, e.tag, 0xffffffffu);
    ++k_.retired;
    k_.retire_order.push_back(uidSeq(e.tid));
    if (e.op->cls == kExit) k_.exited = true;
    // free-new: retire frees the write's own new register instead of the
    // one it replaced, so a live value is reallocated once the list wraps.
    const unsigned freed = k_.brk == "free-new" ? e.pnew : e.pold;
    if (e.op->gdst && freed != ccv::prov::kPhysZero) free_.push_back(freed);
    rob_.pop_front();
  }

  bool busy() const override {
    return !rob_.empty() || !redirects_.empty() || free_mask_ != 0;
  }
};

} // namespace

/// The Stage 4b model (sim/ooe/), and this stub beside it for A/B runs:
/// CCV_OOE_IMPL=stub selects the stub, in both hosts.
std::unique_ptr<Block> makeOoeModel(int inst, Kernel &k);

std::unique_ptr<Block> makeOoe(int inst, Kernel &k) {
  const char *impl = std::getenv("CCV_OOE_IMPL");
  if (impl && std::string(impl) == "stub") return std::make_unique<Ooe>(inst, k);
  return makeOoeModel(inst, k);
}

} // namespace skel
} // namespace ccv
