//===-- rcu_block.cpp - the RCU model at the swap boundary ----------------===//
//
// Unpacks RCU's channels into rcu::Core's structs and packs its outputs
// back, and nothing else: the core holds every structure, timing and
// decision. Reads only RCU's own receivers and writes only its own senders
// (stub.h); the oracle is consulted for checks, never for decisions.
//
// What lives here rather than in the core:
//   - the op-class decode, from the skeleton's op table (the RTL's comes from
//     a generated table, Pipeline tab);
//   - the testbench hooks: Kernel::gpr and Kernel::pred as the register
//     files, the restore's maps for the final compare, coverage bins, check
//     failures, and the oracle checks of what R computes;
//   - the receivers of the three non-fixed-latency inputs (map, command and
//     PCA rows) as the storage behind the core's queues: a message stays in
//     its receiver until the core frees its entry, so its credit returns
//     when the spec returns it.
//   - CCV_RCU_EVLOG=<file>: the core's events, one a line.
//===----------------------------------------------------------------------===//
#include "stub.h"
#include "rcu_core.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <memory>

namespace ccv {
namespace skel {
namespace {

namespace R = ccv::rcu;

inline unsigned getSec(const Bits &b, unsigned chan, const char *f, unsigned k, unsigned w) {
  return unsigned(b.get(field(chan, f).lsb + w * k, w));
}
inline void putSec(Bits &b, unsigned chan, const char *f, unsigned k, unsigned w, unsigned v) {
  b.set(field(chan, f).lsb + w * k, w, v);
}

/// The op-class decode (Pipeline tab) of an opcode, from the op table.
R::OpClass classOf(const OpInfo *op, bool copy, bool pred_copy) {
  R::OpClass oc;
  if (copy) {
    oc.unit = pred_copy ? R::Unit::PredCopy : R::Unit::Copy;
    oc.guarded = true;   // a copy's active lanes are issue mask AND guard
    return oc;
  }
  oc.guarded = op->guard;
  oc.pdata = op->pdata;
  oc.gdst = op->gdst;
  for (unsigned i = 0; i != op->nsrc; ++i)
    if (!(op->alu_imm >= 0 && int(i) == op->imm_slot)) oc.reads |= 1u << i;
  oc.imm_used = op->alu_imm >= 0 || op->srd_sel >= 0 || op->cls == kPredLogic;
  oc.base_src = op->base_src;
  oc.index_src = op->index_src;
  oc.data_src = op->data_src;
  const bool mem = op->cls == kLoad || op->cls == kStore || op->cls == kFence;
  if (mem) {
    oc.unit = R::Unit::Mem;
    oc.mk = op->cls == kFence ? R::MemKind::Fence
            : op->cls == kLoad ? (op->pxfer ? R::MemKind::PredLoad : R::MemKind::Load)
                               : (op->pxfer ? R::MemKind::PredStore : R::MemKind::Store);
    // A predicate transfer's active mask is the issue mask (TI-36).
    if (op->pxfer) oc.guarded = false;
    return oc;
  }
  if (op->cross) {
    oc.unit = R::Unit::Coll;
    oc.rk = R::RKind::ShflIdxImm;   // the op table's one collective: shfl.idx #lane
    return oc;
  }
  if (inRcu(op->cls)) {
    oc.unit = R::Unit::ROnly;
    switch (op->cls) {
    case kBranch: oc.rk = op->ret ? R::RKind::Ret : op->gdst ? R::RKind::Call : R::RKind::Bra; break;
    case kPredLogic:
      oc.rk = !std::strcmp(op->name, "POR") ? R::RKind::Por
              : !std::strcmp(op->name, "PAND") ? R::RKind::Pand
              : !std::strcmp(op->name, "PXOR") ? R::RKind::Pxor : R::RKind::None;
      break;
    case kImm: oc.rk = op->pwrite ? R::RKind::PmovImm : R::RKind::Movi; break;
    default: break;
    }
    // ret reads its link register as R0 (the op table lists it as nsrc).
    if (op->ret) oc.reads |= 1u;
    return oc;
  }
  oc.unit = R::Unit::Lane;
  oc.imm_slot = op->alu_imm >= 0 ? op->imm_slot : -1;
  return oc;
}

class RcuModel : public Stub, R::Hooks {
public:
  RcuModel(int inst, Kernel &k)
      : Stub(inst, k), core_(config(k), R::Files{&k.gpr, &k.pred}, *this) {
    // A register file comes up holding garbage: each physical GPR a distinct
    // pattern, so a read of one nothing wrote cannot pass by reading zero.
    // The zero registers read zero (A-64): they have no row.
    k.gpr.assign(256, {});
    for (unsigned p = 0; p != ccv::prov::kPhysRegs; ++p)
      for (unsigned l = 0; l != R::kLanes; ++l) k.gpr[p][l] = 0xdead0000u | p << 5 | l;
    k.pred.assign(256, 0);
    const Ch &c = ch();
    // Map, command and PCA rows wait in their receivers until the core frees
    // their entries: that is when their credits return (Migration tab).
    holdsBack(c.pca_rcu);
    holdsBack(c.ooe_map);
    holdsBack(c.rau_rcu_mig);
    if (const char *p = std::getenv("CCV_RCU_EVLOG")) evlog_ = std::fopen(p, "w");
  }
  ~RcuModel() override {
    if (evlog_) std::fclose(evlog_);
  }
  const char *kind() const override { return "rcu"; }

private:
  static R::Config config(Kernel &k) {
    R::Config cfg;
    cfg.brk = k.brk;
    // AR-24's interim (no narrowing in this build); CCV_RCU_FULL_ROW=0 runs
    // the Register file tab's secmask writes instead.
    const char *fr = std::getenv("CCV_RCU_FULL_ROW");
    cfg.full_row = !(fr && std::string(fr) == "0");
    if (const char *kc = std::getenv("CCV_RCU_KILL_DRAIN_CUT")) cfg.kill_drain_cut = unsigned(std::atoi(kc));
    for (const ChanInst &ci : kChanInsts) {
      if (ci.chan == chanId("ccv_ooe_rcu_issue")) cfg.issue_stages = std::max(cfg.issue_stages, unsigned(ci.stages + ci.bnd_rx));
      if (ci.chan == chanId("ccv_rcu_ooe_done")) cfg.done_stages = std::max(cfg.done_stages, unsigned(ci.stages + ci.bnd_rx));
    }
    return cfg;
  }

  // ---- hooks --------------------------------------------------------------------
  void fail(const std::string &m) override { k_.fail("%s", m.c_str()); }
  void event(const R::Event &e) override {
    if (evlog_)
      std::fprintf(evlog_, "%llu %s %u %u %u %u\n", (unsigned long long)e.t, R::evName(e.ev), e.a, e.b, e.c, e.d);
    // The trace's events (schema/events.json, ids 33-47, TI's 6cbabba): the
    // core's four fields packed into the schema's three. No RCU event names
    // one instruction, so uid is 0. docs/rcu-model.md has the packing.
    using E = R::Ev;
    switch (e.ev) {
    case E::GprWrite: emit(e.t, 0, EV_RCU_GPR_WRITE, UNIT_RCU, e.a, e.b, e.d << 4 | e.c); break;
    case E::PredWrite: emit(e.t, 0, EV_RCU_PRED_WRITE, UNIT_RCU, e.a, e.b, e.d); break;
    case E::Branch: emit(e.t, 0, EV_RCU_BRANCH, UNIT_RCU, e.a, e.c, e.d); break;
    case E::GuardFwd: emit(e.t, 0, EV_RCU_GUARD_FWD, UNIT_RCU, e.a, e.b, e.c); break;
    case E::RsrcFwd: emit(e.t, 0, EV_RCU_RSRC_FWD, UNIT_RCU, e.a, e.b, e.c); break;
    case E::BypassSel: emit(e.t, 0, EV_RCU_BYPASS_SEL, UNIT_RCU, e.a, e.b, e.c | e.d << 8); break;
    case E::KillDrain: emit(e.t, 0, EV_RCU_KILL_DRAIN, UNIT_RCU, e.a, e.b, e.c); break;
    case E::KillAck: emit(e.t, 0, EV_RCU_KILL_ACK, UNIT_RCU, e.a); break;
    case E::MigPair: emit(e.t, 0, EV_RCU_MIG_PAIR, UNIT_RCU, e.a, e.b); break;
    case E::MigRowOut: emit(e.t, 0, EV_RCU_MIG_ROW_OUT, UNIT_RCU, e.a, e.b); break;
    case E::MigRowIn: emit(e.t, 0, EV_RCU_MIG_ROW_IN, UNIT_RCU, e.a, e.b); break;
    case E::MigWaitR: emit(e.t, 0, EV_RCU_MIG_WAIT, UNIT_RCU, e.a, e.b, 0); break;
    case E::MigWaitCredit: emit(e.t, 0, EV_RCU_MIG_WAIT, UNIT_RCU, e.a, e.b, 1); break;
    case E::RestoreHold: emit(e.t, 0, EV_RCU_RESTORE_HOLD, UNIT_RCU, e.a); break;
    case E::RestoreDone: emit(e.t, 0, EV_RCU_RESTORE_DONE, UNIT_RCU, e.a); break;
    case E::Idle: emit(e.t, 0, EV_RCU_IDLE, UNIT_RCU, 1); break;
    case E::Wake: emit(e.t, 0, EV_RCU_IDLE, UNIT_RCU, 0); break;
    }
  }
  void hit(const char *bin) override { k_.hit(bin); }
  void restored(const R::MapMsg &m) override {
    // The predicate row closes the transfer: the warp's maps, for the final
    // compare, are the restore map's (an observation).
    for (unsigned a = 0; a != R::kArchGprs; ++a) k_.ratOf(m.warp)[a] = m.gpr[a];
    if (!k_.prat.empty() && m.warp < k_.prat.size() && !k_.prat[m.warp].empty())
      for (unsigned p = 0; p != R::kArchPreds; ++p) k_.prat[m.warp][p] = m.pred[p];
  }
  void rResult(const R::Issue &is, uint32_t lanes, const R::Word &gnew, uint32_t em, bool pw,
               uint32_t pval) override {
    const OpInfo *op = opByCode(is.opcode);
    if (!op) return;
    const Record *r = rec(is.tid, "rcu");
    if (r && inRcu(op->cls) && perLaneInput(op, *r))
      k_.fail("rcu: %s has a per-lane input; the lane executes it (Q-32)", op->name);
    // A collective is judged, as a lane's op is, only on its last execution:
    // OOE wakes it early behind an L1 load and replays it on a miss.
    if (op->cross) k_.executing("rcu", is.tid);
    if (!r) return;
    if (pw)
      if (const RegVal *d = r->predDef())
        if (pval != d->p)
          k_.fail("rcu: seq %llu P%u = %08x, oracle %08x", (unsigned long long)r->seq, d->idx, pval, d->p);
    if (op->gdst && !op->ret) {
      const RegVal *d = r->gprDef();
      if (!d) { k_.fail("rcu: seq %llu writes a GPR ccv-sim does not", (unsigned long long)r->seq); return; }
      for (unsigned l = 0; l != R::kLanes; ++l)
        if (((lanes >> l) & 1u) && (gnew[l] & em) != (d->v[l] & em)) {
          if (op->cross)
            k_.failHeld("rcu", is.tid, "rcu: seq %llu R%u lane %u = %08x, oracle %08x", (unsigned long long)r->seq,
                        d->idx, l, gnew[l], d->v[l]);
          else
            k_.fail("rcu: seq %llu R%u lane %u = %08x, oracle %08x", (unsigned long long)r->seq, d->idx, l,
                    gnew[l], d->v[l]);
          break;
        }
    }
  }
  void branch(const R::Issue &is, const R::Done &d, uint32_t active) override {
    const OpInfo *op = opByCode(is.opcode);
    const Record *r = rec(is.tid, "rcu");
    if (!op || !r) return;
    if (!op->ret) {
      if (r->taken != d.bm)
        k_.fail("rcu: seq %llu branch taken by %08x, oracle %08x", (unsigned long long)r->seq, d.bm, r->taken);
      return;
    }
    // A ret's lanes are judged by target, a pass at a time, and held: OOE
    // may issue it on a speculated L1 hit and replay it (CP-54). A pass is
    // its active lanes, as the stub keys it: keyed by the lanes returned, a
    // speculated issue on stale data returns other lanes than its replay, so
    // the replay never clears its failure (coremark32, RI-16's runs).
    const std::string at = "rcu ret " + std::to_string(active);
    k_.executing(at, is.tid);
    if (d.bm && d.aux != uint32_t(r->target))
      k_.failHeld(at, is.tid, "rcu: seq %llu ret to %08x, oracle %08llx", (unsigned long long)r->seq, d.aux,
                  (unsigned long long)r->target);
    if (d.bm != r->taken)
      k_.failHeld(at, is.tid, "rcu: seq %llu ret pass returns lanes %08x, oracle %08x", (unsigned long long)r->seq,
                  d.bm, r->taken);
  }

  // ---- decode ---------------------------------------------------------------------
  R::Issue decode(const Receiver::Msg &m) {
    const Ch &c = ch();
    const Bits &p = m.payload;
    R::Issue is;
    is.tid = m.tid;
    is.cont = get(p, c.ooe_rcu, "cont") != 0;
    is.tag = unsigned(get(p, c.ooe_rcu, "rob_tag"));
    is.done_row = unsigned(get(p, c.ooe_rcu, "done_row"));
    is.warp = unsigned(get(p, c.ooe_rcu, "warp_id"));
    is.issue_mask = uint32_t(get(p, c.ooe_rcu, "issue_mask"));
    const unsigned ps = unsigned(get(p, c.ooe_rcu, "phys_src"));
    is.src = {(ps >> 8) & 0xffu, ps & 0xffu, unsigned(get(p, c.ooe_rcu, "phys_src2"))};
    for (unsigned i = 0; i != 3; ++i) {
      is.src_pos[i] = getSec(p, c.ooe_rcu, "src_pos", i, ccv::kWPhysPos);
      is.src_w[i] = getSec(p, c.ooe_rcu, "src_width", i, ccv::kWChwidth);
    }
    is.dst = unsigned(get(p, c.ooe_rcu, "phys_dst"));
    is.dst_pos = unsigned(get(p, c.ooe_rcu, "dst_pos"));
    is.dst_w = unsigned(get(p, c.ooe_rcu, "dst_width"));
    is.old_dst = unsigned(get(p, c.ooe_rcu, "phys_old_dst"));
    is.old_pos = unsigned(get(p, c.ooe_rcu, "old_dst_pos"));
    is.pguard = unsigned(get(p, c.ooe_rcu, "phys_pred_guard"));
    is.pneg = get(p, c.ooe_rcu, "pred_neg") != 0;
    is.pdst = unsigned(get(p, c.ooe_rcu, "phys_pred_dst"));
    is.pold = unsigned(get(p, c.ooe_rcu, "phys_pred_old_dst"));
    is.pwe = get(p, c.ooe_rcu, "pred_we") != 0;
    is.merge = get(p, c.ooe_rcu, "merge_en") != 0;
    is.foot = unsigned(get(p, c.ooe_rcu, "footprint"));
    is.imm = uint32_t(get(p, c.ooe_rcu, "imm"));
    is.opcode = unsigned(get(p, c.ooe_rcu, "opcode"));
    is.lead.sec = unsigned(get(p, c.ooe_rcu, "lead_sec_mask"));
    is.lead.src = unsigned(get(p, c.ooe_rcu, "lead_src_used"));
    is.lead.imm = get(p, c.ooe_rcu, "lead_imm_used") != 0;
    is.lead.merge = get(p, c.ooe_rcu, "lead_merge_used") != 0;
    is.lead.guard = get(p, c.ooe_rcu, "lead_guard_used") != 0;
    is.lead.gpred = unsigned(get(p, c.ooe_rcu, "lead_guard_pred"));
    if (is.cont) return is;
    const bool copy = is.opcode == kOpCopy;
    const OpInfo *op = copy ? nullptr : opByCode(is.opcode);
    if (!copy && !op) {
      k_.fail("rcu: unknown opcode %u", is.opcode);
      is.oc.unit = R::Unit::Lane;
      return is;
    }
    is.oc = classOf(op, copy, copy && is.pwe && is.dst == R::kZero);
    is.name = op ? op->name : "a copy";
    // INTERIM until RA-18 lands (DEC's imm_kind 6, OOE's pc + length in
    // imm): call's link is ccv-sim's, as the stub takes it (CP-9, AR-22).
    // The core reads imm as the spec says; only this line feeds it.
    if (is.oc.rk == R::RKind::Call)
      if (const Record *r = rec(is.tid, "rcu"))
        if (const RegVal *ld = r->gprDef()) is.imm = ld->v[0];
    if (k_.brk == "dirty-zero") {
      k_.gpr[R::kZero].fill(0x5a5a5a5au);
      k_.pred[R::kPZero] = 0xa5a5a5a5u;
    }
    return is;
  }
  /// A message landed in a held-back receiver this cycle: its newest, once.
  /// This block's own receiver of a rate-1 input (its slot 0).
  Receiver &own(unsigned chan) {
    for (const In &i : ins)
      if (i.ci->chan == chan && i.slot == 0) return *i.rx;
    std::fprintf(stderr, "rcu: no input %s\n", kChans[chan].name);
    std::abort();
  }
  bool fresh(unsigned chan, unsigned &seen) {
    Receiver &r = own(chan);
    if (r.size() <= seen) return false;
    ++seen;
    return true;
  }
  const Bits &newest(unsigned chan) { Receiver &r = own(chan); return r.at(r.size() - 1).payload; }

  // ---- the cycle ---------------------------------------------------------------------
  void work() override {
    const Ch &c = ch();
    R::In in;
    for (unsigned s = 0; s != R::kRes; ++s)
      if (has(c.ooe_rcu, s)) in.iss[s] = decode(take(c.ooe_rcu, s));
    // Lane results: all 32 lanes, or it is not lockstep.
    unsigned n = 0;
    for (unsigned l = 0; l != R::kLanes; ++l) n += has(c.lane_rcu, 0, l);
    if (n != 0 && n != R::kLanes) k_.fail("rcu: %u of 32 lanes answered", n);
    if (n == R::kLanes) {
      R::LaneRes r;
      const auto want = lane_tid_.find(now_);
      for (unsigned l = 0; l != R::kLanes; ++l) {
        Receiver::Msg m = take(c.lane_rcu, 0, l);
        if (want != lane_tid_.end() && m.tid != want->second)
          k_.fail("rcu: lane %u answered for another instruction", l);
        r.result[l] = uint32_t(get(m.payload, c.lane_rcu, "result"));
        r.sec_valid[l] = uint8_t(get(m.payload, c.lane_rcu, "sec_valid"));
        r.sec_pred_out[l] = uint8_t(get(m.payload, c.lane_rcu, "sec_pred_out"));
      }
      in.lres = r;
    }
    lane_tid_.erase(now_);
    for (unsigned j = 0; j != R::kPipes; ++j) {
      if (!has(c.miu_rcu, j)) continue;
      Receiver::Msg m = take(c.miu_rcu, j);
      R::MiuData d;
      d.tid = m.tid;
      d.active = uint32_t(get(m.payload, c.miu_rcu, "active_mask"));
      d.pred_result = uint32_t(get(m.payload, c.miu_rcu, "pred_result"));
      d.dst = unsigned(get(m.payload, c.miu_rcu, "phys_dst"));
      d.pos = unsigned(get(m.payload, c.miu_rcu, "dst_pos"));
      d.w = unsigned(get(m.payload, c.miu_rcu, "dst_width"));
      d.ppred = unsigned(get(m.payload, c.miu_rcu, "phys_pred"));
      d.pwe = get(m.payload, c.miu_rcu, "pred_we") != 0;
      for (unsigned l = 0; l != R::kLanes; ++l) d.data[l] = getLane(m.payload, c.miu_rcu, "load_data", l);
      in.mdat[j] = d;
    }
    if (fresh(c.ooe_map, seen_map_)) {
      const Bits &m = newest(c.ooe_map);
      R::MapMsg mm;
      mm.warp = unsigned(get(m, c.ooe_map, "warp_id"));
      mm.dir = unsigned(get(m, c.ooe_map, "direction"));
      const FieldDesc &gm = field(c.ooe_map, "gpr_map"), &pm = field(c.ooe_map, "pred_map");
      const unsigned gw = gm.width / R::kArchGprs, pwd = pm.width / R::kArchPreds;
      for (unsigned a = 0; a != R::kArchGprs; ++a) mm.gpr[a] = unsigned(m.get(gm.lsb + a * gw, gw));
      for (unsigned q = 0; q != R::kArchPreds; ++q) mm.pred[q] = unsigned(m.get(pm.lsb + q * pwd, pwd));
      in.map = mm;
    }
    if (fresh(c.rau_rcu_mig, seen_cmd_)) {
      const Bits &m = newest(c.rau_rcu_mig);
      in.cmd = R::CmdMsg{unsigned(get(m, c.rau_rcu_mig, "warp_id")), unsigned(get(m, c.rau_rcu_mig, "direction"))};
    }
    if (fresh(c.pca_rcu, seen_pca_)) {
      const Bits &m = newest(c.pca_rcu);
      R::MigRow r;
      r.warp = unsigned(get(m, c.pca_rcu, "warp_id"));
      r.row = unsigned(get(m, c.pca_rcu, "mig_row"));
      const unsigned dl = field(c.pca_rcu, "row_data").lsb;
      for (unsigned l = 0; l != R::kLanes; ++l) r.data[l] = uint32_t(m.get(dl + 32 * l, 32));
      in.pca = r;
    }
    in.pca_can_send = can(c.rcu_pca, 0);
    for (unsigned s = 0; s != R::kDoneSlots; ++s) in.done_can[s] = can(c.rcu_ooe, s);
    for (unsigned j = 0; j != R::kPipes; ++j) in.addr_can[j] = can(c.rcu_miu, j);
    for (unsigned l = 0; l != R::kLanes; ++l) in.lane_can = in.lane_can && can(c.rcu_lane, 0, l);

    R::Out out;
    core_.cycle(now_, in, out);

    if (out.lane && in.lane_can) {
      for (unsigned l = 0; l != R::kLanes; ++l) send(c.rcu_lane, 0, laneMsg(*out.lane, l), out.lane->tid, l);
      lane_tid_[now_ + R::kLaneW] = out.lane->tid;
    }
    for (const R::Done &d : out.dones) {
      if (d.slot >= R::kDoneSlots || !can(c.rcu_ooe, d.slot)) continue;
      Bits m = msgOf(c.rcu_ooe);
      put(m, c.rcu_ooe, "rob_tag", d.tag);
      put(m, c.rcu_ooe, "done_row", d.row);
      if (d.bt) put(m, c.rcu_ooe, "branch_taken", 1);
      if (d.bm) put(m, c.rcu_ooe, "branch_mask", d.bm);
      if (d.aux || d.aux_set) put(m, c.rcu_ooe, "aux", d.aux_set ? 1u : d.aux);
      if (d.lbt) put(m, c.rcu_ooe, "lead_br_taken", 1);
      if (d.lbm) put(m, c.rcu_ooe, "lead_br_mask", d.lbm);
      send(c.rcu_ooe, d.slot, m, d.tid);
    }
    for (const R::Addr &a : out.addrs) {
      if (!can(c.rcu_miu, a.slot)) continue;
      Bits m = msgOf(c.rcu_miu);
      put(m, c.rcu_miu, "rob_tag", a.tag);
      put(m, c.rcu_miu, "active_mask", a.active);
      for (unsigned l = 0; l != R::kLanes; ++l) {
        putLane(m, c.rcu_miu, "base_per_lane", l, a.base[l]);
        putLane(m, c.rcu_miu, "index_per_lane", l, a.index[l]);
        putLane(m, c.rcu_miu, "store_data", l, a.data[l]);
      }
      send(c.rcu_miu, a.slot, m, a.tid);
    }
    if (out.pca) {
      Bits m = msgOf(c.rcu_pca);
      put(m, c.rcu_pca, "warp_id", out.pca->warp);
      put(m, c.rcu_pca, "mig_row", out.pca->row);
      const unsigned dl = field(c.rcu_pca, "row_data").lsb;
      for (unsigned l = 0; l != R::kLanes; ++l) m.set(dl + 32 * l, 32, out.pca->data[l]);
      send(c.rcu_pca, 0, m, makeUid(IdClass::kNone, 0));
    }
    if (out.map_credit) { take(c.ooe_map, 0); --seen_map_; }
    if (out.cmd_credit) { take(c.rau_rcu_mig, 0); --seen_cmd_; }
    if (out.pca_credit) { take(c.pca_rcu, 0); --seen_pca_; }
  }

  Bits laneMsg(const R::LaneMsg &lm, unsigned l) {
    const Ch &c = ch();
    Bits o = msgOf(c.rcu_lane);
    unsigned en = 0;
    for (unsigned k = 0; k != R::kSecs; ++k) {
      const R::LaneSec &s = lm.sec[k];
      if (!s.en) continue;
      en |= 1u << k;
      putSec(o, c.rcu_lane, "sec_opcode", k, ccv::prelim::kWOpcode, s.opcode);
      putSec(o, c.rcu_lane, "sec_owner", k, ccv::kWPhysPos, s.owner);
      for (unsigned i = 0; i != R::kPorts; ++i) {
        putSec(o, c.rcu_lane, "sec_opnd_pos", k * R::kPorts + i, ccv::kWPhysPos, s.pos[i]);
        putSec(o, c.rcu_lane, "sec_opnd_width", k * R::kPorts + i, ccv::kWChwidth, s.w[i]);
        putSec(o, c.rcu_lane, "operand_byp", k * R::kPorts + i, ccv::prov::kWLaneBypSel, s.byp[i]);
      }
      putSec(o, c.rcu_lane, "sec_dst_pos", k, ccv::kWPhysPos, s.dst_pos);
      putSec(o, c.rcu_lane, "sec_dst_width", k, ccv::kWChwidth, s.dst_w);
    }
    put(o, c.rcu_lane, "section_en", en);
    const unsigned olsb = field(c.rcu_lane, "operand").lsb;
    for (unsigned i = 0; i + 1 < R::kPorts; ++i) o.set(olsb + 32 * i, 32, lm.opnd[l][i]);
    put(o, c.rcu_lane, "merge_data", lm.opnd[l][R::kMergePort]);
    put(o, c.rcu_lane, "sec_pred_bit", lm.pred_bit[l]);
    put(o, c.rcu_lane, "sec_pred_data", lm.pred_data[l]);
    return o;
  }

  void onKill(uint32_t mask, unsigned epoch) override { core_.kill(mask, epoch); }
  bool killQuiet(uint32_t) const override { return core_.killQuiet(); }
  bool busy() const override { return !core_.idle(); }

  R::Core core_;
  std::FILE *evlog_ = nullptr;
  unsigned seen_map_ = 0, seen_cmd_ = 0, seen_pca_ = 0;
  std::map<uint64_t, uint64_t> lane_tid_;   ///< the lane message's tid, by its results' cycle
};

} // namespace

/// The RCU model (sim/rcu/), behind TI's makeRcu hook (RA-38).
std::unique_ptr<Block> makeRcuModel(int inst, Kernel &k) { return std::make_unique<RcuModel>(inst, k); }

} // namespace skel
} // namespace ccv
