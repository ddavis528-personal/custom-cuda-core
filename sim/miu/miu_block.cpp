//===-- miu_block.cpp - the MIU model at the swap boundary ----------------===//
//
// MI's cycle-accurate model of the MIU (docs/miu-impl.md; MIU tab of the
// per-block specs, pinned at docs/design-snapshots/miu-spec.md). It reads
// only MIU's own receivers and writes only its own senders (stub.h); the
// oracle is consulted for checks, never for decisions.
//
// It starts as the stub's function (class Miu in sim/skel/kernel.cpp: the
// address forms, faults, windows, SPM and atomic passes, the st.pred drain,
// hints, replay, orphans and every control hook), and takes MA's Phase 1
// timing and structures in place of the stub's, step by step, each step run
// against every kernel and control. CCV_MIU_IMPL=model selects it (TI's
// makeMiu, MI-1); the stub stays the default until M0.
//===----------------------------------------------------------------------===//
#include "stub.h"
#include "miu_res.h"
#include "miu_ids.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <list>
#include <map>
#include <memory>
#include <set>
#include <tuple>
#include <vector>

namespace ccv {
namespace skel {
namespace {

// AR 362, AR 364: ccv_miu_dcu_req's set-index lead, the lookup's physical
// address bits [log2 line + CCV_W_DCU_SET - 1 : log2 line] (as kernel.cpp's).
inline uint64_t indexLeadSet(uint64_t pa) {
  static_assert((1u << 7) == kLine, "a line is 128 bytes");
  return (pa >> 7) & ((uint64_t(1) << ccv::prov::kWDcuSet) - 1);
}

class MiuModel : public Stub {
public:
  MiuModel(int inst, Kernel &k)
      : Stub(inst, k), ids_(field(ch().miu_dcu, "req_id").width, kChans[ch().miu_dcu].rate, "CCV_MIU_DCU_IDS"), spm_ids_(ch().miu_spm) {
    ids_.borrow = envOn("CCV_MIU_IDS_BORROW");
  }
  const char *kind() const override { return "miu"; }
  ~MiuModel() override {
    if (!pbins_) return;
    std::fprintf(stderr, "MIUBINS");
    for (const char *n : {"credit_hold_other_bank", "dcu_id_quarter_empty", "dcu_id_drop_held",
                          "l0_lookup", "l0_miss", "l0_refill_wait"}) {
      const auto it = pbin_.find(n);
      std::fprintf(stderr, " %s=%llu", n, (unsigned long long)(it == pbin_.end() ? 0 : it->second));
    }
    std::fprintf(stderr, "\n");
  }

private:
  /// discarded: a bulk discard covered it before its address came, so the
  /// address ends it with a replay completion (TI-21).
  struct Memop { unsigned slot; Bits msg; uint64_t at; uint64_t tid; bool discarded = false; };
  struct Addr { unsigned slot; Bits msg; uint64_t tid; };
  struct LineReq {
    uint64_t line; Line data{}; std::array<bool, kLine> mask{}; uint16_t sub;
    bool sent = false;               ///< its request has gone to DCU
  };
  struct Job {
    bool store = false;
    bool ecc = false;   ///< a line came with a non-zero syndrome (R2; MA-28 (c), AR 401)
    unsigned tag = 0, memop_slot = 0, addr_slot = 0, warp = 0;
    unsigned phys_dst = 0, phys_pred = 0;   ///< echoed on miu_rcu_data
    unsigned rs_idx = 0;                    ///< echoed on miu_ooe_cmpl (OA-23)
    unsigned dst_pos = 0, chw = 0;          ///< likewise: the slice a load writes
    uint32_t active = 0;             ///< lanes that may access memory
    uint64_t tid = 0;
    std::array<uint64_t, kLanes> addr{};
    std::vector<LineReq> lines;
    unsigned next = 0, back = 0;     ///< lines requested / answered
    /// The first pass (MA-4): each lane group's deduplicated leader line on
    /// the group's slot of the footprint, (slot, index into lines), sent at
    /// H+1. Empty for what has none (stores, atomics, SPM, drains).
    std::vector<std::pair<unsigned, unsigned>> fp;
    uint64_t h = 0;                  ///< its A1 cycle
    uint64_t issue_at = 0;           ///< the memop's arrival, for the no-hit's cycle
    bool first = false;              ///< its first pass is still to go
    std::map<uint64_t, Line> got;
    bool global = false;             ///< .global: the L1 contract applies
    bool hit = true;                 ///< every line hit in DCU
    bool mlc_miss = false;           ///< some line's fill missed MLC
    uint64_t due = 0;                ///< a global load's L1-contract cycle
    uint64_t serial = 0;             ///< names it to the DCU responses
    uint64_t promised = 0;           ///< a hinted completion's launch cycle, or 0 (OA-23)
    bool moot = false;               ///< a kill supplied lines DCU still owed: its data is moot
    bool frame = false;              ///< its lanes span windows: O-30 frames (AR-23)
    bool entry = false;              ///< a store holding its MQ entry until it drains
    bool walk = false;               ///< the walker's PTE read, not a memop
    /// MA-4's eligibility lost from the address alone (lane group, page,
    /// bank): never an L1 hit, and MIU says so early with a no-hit (AR 356).
    bool inelig = false;
    /// A predicate transfer (TI-36): one word at lane 0's address. A store
    /// carries its predicate's word, merged into memory's after commit.
    bool pxfer = false;
    unsigned bytes = 4;              ///< per lane: the transfer
    unsigned xsize = 0;              ///< O-80's xfer_size, from the memop
    bool xsigned = false;            ///< and xfer_signed
    uint32_t pdata = 0;
    unsigned rmw = 0;                ///< a predicate store's drain: 1 reading, 2 writing
    unsigned atom = 0;               ///< an atomic's pass (AR-21): 1 its read, 3 its write
    /// .shared (TI's rev 230): SPM's, in passes of at most one word a bank,
    /// not DCU's lines. addr is the CTA-relative offset ccv-sim names, and
    /// paddr SPM's byte address. lines still name what it touches, keyed
    /// apart from .global's (kSpmKey), for the ordering checks.
    bool spm = false;
    struct Pass {
      std::array<uint16_t, ccv::kSpmBanks> word{};
      std::array<bool, ccv::kSpmBanks> used{};
      Line data{};
      std::array<bool, kLine> mask{};
    };
    std::vector<Pass> passes;
    std::array<uint8_t, kLanes> lane_pass{};
    std::array<uint64_t, kLanes> paddr{};
    unsigned pnext = 0, pback = 0;   ///< passes sent / answered
  };
  static_assert(kLine == 4 * ccv::kSpmBanks, "an SPM pass is a line's bytes, a word a bank");
  static constexpr uint64_t kSpmKey = uint64_t(1) << 63;
  /// The line a lane's access lies in, and its byte there: SPM's, keyed
  /// apart, for .shared.
  static uint64_t keyOf(const Job &j, unsigned l) {
    return j.spm ? kSpmKey | (j.paddr[l] / kLine * kLine) : j.addr[l] / kLine * kLine;
  }
  static unsigned offOf(const Job &j, unsigned l) {
    return unsigned((j.spm ? j.paddr[l] : j.addr[l]) % kLine);
  }
  /// A predicate transfer's oracle access: the uop's word, its sub-th of
  /// the instruction's, ascending (TI-36).
  static const MemAcc *xferAcc(const Record *r, uint64_t tid) {
    return r && uidSub(tid) < r->mem.size() ? &r->mem[uidSub(tid)] : nullptr;
  }
  /// A hit's completion and data, held for the contract cycle.
  struct Timed { uint64_t at; Q data, cmpl; bool data_only = false; bool ecc = false; };
  std::vector<Timed> held_;   ///< ineligible loads' completions, held past the contract (MA-4)
  /// An L1 hit whose line came with a non-zero syndrome (RA 153 (5); MA-28
  /// (c), AR 401): R2 computes it from ccv_dcu_miu_rsp's check_bits, the OR
  /// over every code word the slot carries (fixLine, which also corrects
  /// the line); DCU's CCV_DCU_ECC_INJECT reaches it. Its data leaves on time
  /// with one bit flipped, as the speculative data would; no completion at
  /// the contract (the miss indication, CCV_LAT_L1_ECC's contract); the
  /// corrected data and then the completion CCV_LAT_L1_ECC + 2 cycles after
  /// the data, as a miss's would come (held_, data before completion).
  /// Corrected beats alone (the controls), each at its cycle.
  std::vector<std::pair<uint64_t, Q>> ecc_beats_;
  std::deque<Timed> timed_;

  std::map<unsigned, Memop> memop_;
  std::map<unsigned, Addr> addr_;
  /// Each CTA slot's .shared region in SPM, its first and last bytes, from
  /// RAU; SPM's requests in flight, by req_id, their job and pass; and the
  /// ones a bulk discard abandoned, by req_id, their warp (TI-21).
  std::map<unsigned, std::pair<uint64_t, uint64_t>> spm_;
  IdPool spm_ids_;
  std::map<unsigned, std::pair<uint64_t, unsigned>> spm_out_;
  std::map<unsigned, unsigned> spm_orphan_;
  /// F-RO's .const range by CTA slot, [base, limit), from RAU (TI-26).
  std::map<unsigned, std::pair<uint64_t, uint64_t>> ro_;
  /// The lanes of a store F-RO refuses (AR's responses TI-26): any lane
  /// whose four bytes touch the launch window (address bits [47:16] equal
  /// to 2, the whole window) or the CTA's .const range. Compared on the
  /// effective address, which this MIU never maps. no-ro drops the check.
  uint32_t roLanes(const Job &j, unsigned cta) const {
    if ((!j.store && !j.atom) || !j.global || k_.brk == "no-ro") return 0;   // an atomic writes
    const auto r = ro_.find(cta);
    const uint64_t base = r == ro_.end() ? 0 : r->second.first;
    const uint64_t limit = r == ro_.end() ? 0 : r->second.second;
    uint32_t ro = 0;
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!(j.active >> l & 1u)) continue;
      const uint64_t a = j.addr[l];
      const bool launch = (a >> 16) == 2 || ((a + 3) >> 16) == 2;
      const bool cnst = a < limit && a + 4 > base;
      if (launch || cnst) ro |= 1u << l;
    }
    return ro;
  }
  /// The launch-slot windows (TI-31, AR's response): by CTA slot, the
  /// sixteen 32-bit words at launch_block_addr + 32 + 8k and their valid
  /// bits. Filled a line at a time on first use; cleared on the slot's
  /// rau_miu_cta and on a kill.
  /// gen counts the clears: a fill sent before one lands nothing.
  /// Entry kLocalBase is O-69's local_base, the word at byte 24 (IS-19).
  /// For the check that a CTA slot names one CTA: each slot's CTA and each
  /// CTA's slot, with the warp first seen naming it.
  std::map<unsigned, std::pair<unsigned, unsigned>> slot_cta_, cta_slot_;
  struct Windows {
    uint64_t block = 0;
    std::array<uint32_t, 17> w{};
    uint32_t valid = 0;
    unsigned gen = 0;
    void clear() { valid = 0; ++gen; }
  };
  std::map<unsigned, Windows> win_;
  /// Each memop's ROB row (OI-85), echoed on its completion.
  std::map<unsigned, unsigned> cmpl_row_;
  /// Each CTA slot's local_base, from its ccv_rau_miu_cta (TI-47).
  std::map<unsigned, uint64_t> lbase_;
  /// A window fill's request to DCU, by req_id: its CTA slot and line, and
  /// the table's gen when it was sent.
  struct Fill { unsigned cta; uint64_t line; unsigned gen; };
  std::map<unsigned, Fill> fills_;
  /// Memops that waited on a fill: an L1 miss, whatever DCU says.
  std::set<unsigned> win_miss_;
  static constexpr unsigned kLocalBase = 16;
  static uint64_t slotAddr(const Windows &t, unsigned k) {
    return k == kLocalBase ? t.block + 24 : t.block + 32 + 8 * k;
  }
  /// Every slot of `t` in `line`, filled from it.
  static void fillWindows(Windows &t, uint64_t line, const Line &d) {
    for (unsigned k = 0; k != 17; ++k) {
      const uint64_t a = slotAddr(t, k);
      if (a / kLine * kLine != line) continue;
      uint32_t v = 0;
      for (unsigned b = 0; b != 4; ++b) v |= uint32_t(d[a % kLine + b]) << (8 * b);
      t.w[k] = v;
      t.valid |= 1u << k;
    }
  }
  void onKill(uint32_t mask, unsigned) override {
    for (auto &t : win_) t.second.clear();
    // OA 436 (TI-485 (5)(a), MA rev 104): MIU completes every memop of a
    // killed warp. A killed warp's atomic keeps its pass and its hold until
    // its write step, whose completion ends it (more 0) and lets the hold
    // go (atomDone); none starts a further pass (OOE's kill_stops).
    // Control kill-drop-atomic: the kill drops the atomic, as before, and
    // its write then finds no read.
    if (k_.brk == "kill-drop-atomic")
      for (auto it = atom_.begin(); it != atom_.end();)
        it = mask >> (it->second.warp & 31) & 1u ? atom_.erase(it) : std::next(it);
    killed_ |= mask;
    // A killed warp's read still owed by DCU is taken as answered now, with
    // no data, and DCU's answer, if one comes, is dropped (kill_drop_):
    // each job, load, store or atomic, then ends on its own path (a
    // promised load at its promise), so MIU owes no killed warp anything.
    // DCU withholds the read a core-fatal UE hit (AR 389), and this is how
    // MIU completes it (OA 436; TI-487 option (3)). A walk belongs to no
    // warp and runs on.
    for (Job &j : jobs_) {
      if (j.walk || !(mask >> (j.warp & 31) & 1u)) continue;
      for (auto o = outstanding_.begin(); o != outstanding_.end();)
        if (o->second.first == j.serial) {
          kill_drop_.insert(o->first);
          j.got[o->second.second] = Line{};
          ++j.back;
          j.moot = true;
          k_.hit("kill_cmpl");
          o = outstanding_.erase(o);
        } else {
          ++o;
        }
    }
  }
  uint32_t killed_ = 0;                 ///< warps a kill has ended
  std::set<unsigned> kill_drop_;        ///< req_ids whose answer a kill made moot
  /// req_ids whose first answer carried a UE (a double-bit syndrome on any
  /// word): kept live for DCU's second answer from the refetch (AR 370; MIU
  /// tab rev 163, ECC; DCU tab slice 2 part 4).
  std::set<unsigned> ue_first_;
  /// True when any word of the answer's line has a double-bit syndrome. No
  /// ue field rides dcu_miu_rsp: R2's syndrome is the only mark.
  static bool lineUe(const Bits &payload, uint32_t data_lsb, uint32_t chk_lsb) {
    const Line ln = getLine(payload, data_lsb);
    for (unsigned w = 0; w != kLineWords; ++w)
      if (secdedL1().decode(lineWord(ln, w), uint32_t(payload.get(chk_lsb + eccR() * w, eccR()))).ded)
        return true;
    return false;
  }
  /// An atomic in passes (AR-21, V-72), by rob tag: its lanes' addresses
  /// from its first read, the lanes still to run, this pass's, and the
  /// lines the pass holds from its read to its write's ack. Nothing else
  /// reaches a held line, so no access lands between a lane's read and its
  /// write; a pass takes, for each address, its lowest lane left, so lanes
  /// naming one address run in ascending order, as ccv-sim runs them.
  struct Atom {
    std::array<uint64_t, kLanes> addr{}, paddr{};
    uint32_t left = 0, pass = 0;
    bool global = false, spm = false;
    unsigned warp = 0, bytes = 4, passes = 0;
    std::vector<uint64_t> held;
  };
  std::map<unsigned, Atom> atom_;
  /// Whether another atomic's pass holds one of `j`'s lines.
  bool held(const Job &j) const {
    for (const auto &a : atom_)
      if (a.first != j.tag)
        for (uint64_t h : a.second.held)
          for (const LineReq &b : j.lines)
            if (h == b.line) return true;
    return false;
  }
  std::deque<unsigned> order_;               ///< memops, as OOE issued them
  std::map<unsigned, Job> stores_;           ///< awaiting commit, by rob tag
  std::deque<Job> committed_;
  /// A load's fault, held to its L1 contract cycle (V-44).
  std::vector<std::pair<uint64_t, Q>> late_faults_;
  /// Jobs in flight, oldest first, up to CCV_MIU_PIPES (AR-19): each sends
  /// its line requests and completes on its own, so DCU holds requests from
  /// more than one memop and a hit is not held behind an older miss. One
  /// starts a cycle, in issue order; a committed store's write never shares
  /// a line with a job in flight, and a load never with a store's write
  /// queued or in flight, so neither reads a line around the other.
  std::list<Job> jobs_;
  uint64_t serial_ = 0;
  bool dropped_ = false;
  /// DCU's req_ids, as rtl/miu/miu_ids.sv: slot s takes from quarter s
  /// (MI-28). Knobs for pricing: CCV_MIU_IDS_BORROW lets a slot borrow
  /// another quarter's id; CCV_MIU_IDS_DROPFREE launches a drop with no id.
  ccv_miu::MiuIds ids_;
  const bool ids_dropfree_ = envOn("CCV_MIU_IDS_DROPFREE");
  /// A take that slot s cannot make: MA's two bins (MI-28).
  void idStall(unsigned s) {
    if (!ids_.quarterEmpty(s)) return;
    if (ids_.anyFree()) pbin("dcu_id_quarter_empty");
    if (ids_.dropHeld(s)) pbin("dcu_id_drop_held");
  }
  /// The job and line of each request to DCU, by req_id.
  std::map<unsigned, std::pair<uint64_t, uint64_t>> outstanding_;
  std::deque<Q> to_rcu_, to_ooe_, to_dcu_, to_fet_;
  /// Hints promised to OOE (OA-23), each launched at its cycle; and the
  /// credits held back for hinted completions and their data, by slot.
  struct Hint { uint64_t at; Q q; bool no_hit = false; unsigned tag = 0; };
  std::deque<Hint> hints_;
  std::map<std::pair<unsigned, unsigned>, unsigned> resv_;
  /// The replay drain (TI-21): requests a bulk discard abandoned at DCU, by
  /// req_id, and each warp's count of them. Their responses are dropped,
  /// and a warp is reported ready to RAU when its count returns to zero.
  std::map<unsigned, unsigned> orphan_;
  std::map<unsigned, unsigned> orphans_;
  std::deque<Q> to_rau_;
  /// A slot an ordinary message may use: a credit, and one more than the
  /// hinted completions hold back.
  bool free(unsigned chan, unsigned slot) {
    return can(chan, slot) && credits(chan, slot) > resv_[{chan, slot}];
  }
  bool spare(unsigned chan, unsigned slot) {
    return credits(chan, slot) > resv_[{chan, slot}];
  }

  /// A refill notice (OA-23): its refill's valid lands CCV_LAT_FILL_NOTICE
  /// cycles from now, its payload a cycle later, and a load waiting on
  /// nothing else completes as it lands. So the completion launches then
  /// and its hint CCV_LAT_CMPL_HINT + 1 cycles before, on the completion's
  /// slot, with that slot's credit, the hint's and the data's held back.
  void notice(unsigned id) {
    const Ch &c = ch();
    auto o = outstanding_.find(id);
    if (o == outstanding_.end()) return;   // a notice names what DCU owes; nothing here to hint
    for (Job &j : jobs_) {
      if (j.serial != o->second.first) continue;
      if (j.walk || j.store || j.promised || j.next != j.lines.size() || j.back + 1 != j.lines.size())
        return;
      const uint64_t at = now_ + ccv::prov::kLatFillNotice + 1;
      const uint64_t h = at - ccv::kLatCmplHint - 1;
      const unsigned ms = j.memop_slot, as = j.addr_slot;
      if (h < now_ + 1 || !spare(c.cmpl_hint, ms) || !spare(c.miu_ooe, ms) ||
          !spare(c.miu_rcu, as))
        return;
      // A slot carries one message a cycle: DCU may send up to
      // CCV_DCACHE_LOOKUPS notices in one cycle, and a second promise on a
      // slot already promised for that cycle (its hint, its completion or
      // its data) could never be kept. It goes unhinted and completes as a
      // miss; hint-same-slot, the control, promises it anyway.
      if (k_.brk != "hint-same-slot") {
        for (const Hint &o : hints_)
          if (!o.no_hit && o.at == h && o.q.slot == ms) { k_.hit("hint_slot_taken"); return; }
        for (const Job &o : jobs_)
          if (o.promised == at && (o.memop_slot == ms || o.addr_slot == as)) {
            k_.hit("hint_slot_taken");
            return;
          }
      }
      Bits m = msgOf(c.cmpl_hint);
      put(m, c.cmpl_hint, "rs_idx", j.rs_idx);
      put(m, c.cmpl_hint, "rob_tag", k_.brk == "hint-wrong-tag" ? j.tag ^ 1u : j.tag);
      hints_.push_back({h, {ms, m, j.tid}});
      ++resv_[{c.cmpl_hint, ms}];
      ++resv_[{c.miu_ooe, ms}];
      ++resv_[{c.miu_rcu, as}];
      j.promised = at;
      return;
    }
  }

  void work() override {
    const Ch &c = ch();
    // A memop's credit stands for its queue entry (MA-5, AR rev 345): it
    // goes back when the memop's last completion leaves, a discard's as it
    // is taken. OOE's select waits for a credit (OI, efe09c78). The control
    // --break memop-credit-on-take returns it on take, as before MA-5: then
    // more memops hold a slot's queue entries than it has credits.
    if (!armed_) {
      armed_ = true;
      at_entry_ = k_.brk != "memop-credit-on-take";
      if (at_entry_) creditAtRelease(c.ooe_miu);
    }
    // MA-25: DCU's per-bank credit returns (ccv_dcu_miu_cred is fixed
    // latency). MIU's end is no-flop: the payload is captured the cycle it
    // lands and counted the cycle after, as miu_cred counts it (V+2), so a
    // return taken now is counted next cycle (cred_pend_). Every set bit
    // returns a credit MIU spent; one that would take a counter past its
    // reset value is refused by name.
    const uint64_t ent = cred_pend_ent_, std = cred_pend_std_;
    cred_pend_ent_ = cred_pend_std_ = 0;
    while (has(c.dcu_cred, 0)) {
      const Bits m = take(c.dcu_cred, 0).payload;
      cred_pend_ent_ |= get(m, c.dcu_cred, "ent_ret");
      cred_pend_std_ |= get(m, c.dcu_cred, "std_ret");
    }
    {
      for (unsigned b = 0; b != ccv::kDcuBanks; ++b) {
        if (ent >> b & 1u) {
          if (bent_[b] >= int(bqdepth_))
            k_.fail("miu: DCU returned an entry credit for bank %u, which holds all %u (MA-25)",
                    b, bqdepth_);
          else ++bent_[b];
        }
        if (std >> b & 1u) {
          if (bstd_[b] >= int(bstdata_))
            k_.fail("miu: DCU returned a store-data credit for bank %u, which holds all %u (MA-25)",
                    b, bstdata_);
          else ++bstd_[b];
        }
      }
    }
    for (unsigned b : a1_refund_) ++bent_[b];   // A2's drops a cycle ago (MA-27)
    a1_refund_.clear();
    for (unsigned s = 0; s != kChans[c.fill_ntc].rate; ++s)
      while (has(c.fill_ntc, s))
        notice(unsigned(get(take(c.fill_ntc, s).payload, c.fill_ntc, "req_id")));
    for (auto it = hints_.begin(); it != hints_.end();) {
      if (it->at != now_) { ++it; continue; }
      if (it->no_hit) {
        // A no-hit is advice, never a promise (OA 410): it holds no credit,
        // so a refill hint on its slot this cycle wins, and it is dropped
        // when its slot has no free credit or its load is no longer
        // outstanding (a no-hit on anything else is a protocol error).
        bool refill = false, live = false;
        for (const Hint &h : hints_) refill = refill || (!h.no_hit && h.at == now_ && h.q.slot == it->q.slot);
        for (const Job &j : jobs_) live = live || (!j.store && j.tag == it->tag);
        // Or still waiting at A2 (lost_), not yet started.
        live = live || lost_.count(it->tag);
        if (refill || !live || !free(c.cmpl_hint, it->q.slot)) {
          k_.hit("l1_nohit_drop");
        } else {
          send(c.cmpl_hint, it->q.slot, it->q.msg, it->q.tid);
          k_.hit("l1_nohit");
        }
        it = hints_.erase(it);
        continue;
      }
      if (!can(c.cmpl_hint, it->q.slot))
        k_.fail("miu: the hint promised on slot %u at cycle %llu has no credit",
                it->q.slot, (unsigned long long)now_);
      else
        send(c.cmpl_hint, it->q.slot, it->q.msg, it->q.tid);
      --resv_[{c.cmpl_hint, it->q.slot}];
      k_.hit("cmpl_hint");
      it = hints_.erase(it);
    }
    if (has(c.fet_miu, 0)) {
      // FET's ITLB miss: a walk on the shared walker (MA-8), which may wait
      // behind a data-side one; the refill names the page (identity).
      Receiver::Msg m = take(c.fet_miu, 0);
      const uint64_t vpn = get(m.payload, c.fet_miu, "virtual_page");
      // itlb-no-walk: FET's refill answered at once under a cold TLB.
      if (!tlb_on_ || k_.brk == "itlb-no-walk") {
        Bits r = msgOf(c.miu_fet);
        put(r, c.miu_fet, "itlb_refill", vpn);
        to_fet_.push_back({0, r, m.tid});
      } else {
        fet_tid_.emplace(vpn, m.tid);
        walk_tid_.emplace(vpn, m.tid);
        walker_.request(vpn, miu::Walker::kItlb);
      }
    }
    if (has(c.rau_miu, 0)) {
      // A CTA's configuration: of it, F-RO's .const range (TI-26).
      const Bits m = take(c.rau_miu, 0).payload;
      const unsigned cta = unsigned(get(m, c.rau_miu, "cta_slot"));
      ro_[cta] = {get(m, c.rau_miu, "const_base"), get(m, c.rau_miu, "const_limit")};
      spm_[cta] = {get(m, c.rau_miu, "spm_base"), get(m, c.rau_miu, "spm_limit")};
      // And where its launch-slot windows come from; the old launch's go.
      Windows &t = win_[cta];
      t.block = get(m, c.rau_miu, "launch_block_addr");
      t.clear();
      // local_base (TI-47): O-69's spill base and O-83's W, from the CTA's
      // arrival, so neither waits for the launch block's line.
      lbase_[cta] = get(m, c.rau_miu, "local_base");
    }
    for (unsigned s = 0; s != kChans[c.ooe_miu].rate; ++s)
      while (has(c.ooe_miu, s)) {
        Receiver::Msg m = take(c.ooe_miu, s);
        const unsigned tag = unsigned(get(m.payload, c.ooe_miu, "rob_tag"));
        // The memop's pipe footprint (OI-33): its width's span of pipes, from
        // its data position. MIU sizes its per-pipe work by it. A bulk
        // discard's fields are reserved zero (A-41), pipes among them.
        const unsigned chw = unsigned(get(m.payload, c.ooe_miu, "chwidth"));
        const unsigned pos = unsigned(get(m.payload, c.ooe_miu, "dst_pos"));
        const unsigned pipes = unsigned(get(m.payload, c.ooe_miu, "pipes"));
        if (get(m.payload, c.ooe_miu, "mem_op") != kMemBulkDiscard && pipes != maskOf(chw, pos))
          k_.fail("miu: rob tag %u has pipes %x, but a %u-bit memop at position %u takes %x",
                  tag, pipes, 32u >> chw, pos, maskOf(chw, pos));
        // Only a fence carries an ordering (IS-11; AR's response, 0xE).
        const unsigned ord = unsigned(get(m.payload, c.ooe_miu, "ordering"));
        if (ord != 0 && get(m.payload, c.ooe_miu, "mem_op") != kMemFence)
          k_.fail("miu: rob tag %u has ordering %u but is not a fence", tag, ord);
        if (get(m.payload, c.ooe_miu, "mem_op") == kMemBulkDiscard) {
          release(c.ooe_miu, s);   // a discard holds no entry
          discard(m.payload);
          continue;
        }
        // The slot's queue entries: never more than its credits.
        k_.peak("memop_entries_peak", entries_[s] + 1);
        if (++entries_[s] > kChans[c.ooe_miu].credits)
          k_.fail("miu: %u memops hold queue entries on slot %u, over its %u credits (MA-5)",
                  entries_[s], s, unsigned(kChans[c.ooe_miu].credits));
        if (uidClass(m.tid) != IdClass::kInstr)
          k_.fail("miu: rob tag %u is a memop with id class %u; only a discard may carry none",
                  tag, unsigned(uidClass(m.tid)));
        // The CTA slot OOE stamps, RAU's for the warp (TI-34): the window
        // table, F-RO's range and the launch block are indexed by it.
        {
          const unsigned w = unsigned(get(m.payload, c.ooe_miu, "warp_id"));
          const unsigned cs = unsigned(get(m.payload, c.ooe_miu, "cta_slot"));
          if (k_.cta_slot_of.count(w) && cs != k_.cta_slot_of[w]) {
            k_.fail("miu: rob tag %u (warp %u) names CTA slot %u; RAU gave it %u", tag, w, cs,
                    k_.cta_slot_of[w]);
          }
          // A slot is one CTA's, and a CTA has one slot (CP-30): the warps
          // ccv-sim ran as one CTA share its state here, and no other's.
          // Checked once the slot is RAU's, so a memop is refused once.
          else if (w < k_.cta_of.size()) {
            const unsigned cta = k_.cta_of[w];
            auto a = slot_cta_.emplace(cs, std::make_pair(cta, w)).first;
            auto b = cta_slot_.emplace(cta, std::make_pair(cs, w)).first;
            if (a->second.first != cta)
              k_.fail("miu: CTA slot %u holds warp %u of ctaid %u and warp %u of ctaid %u", cs,
                      a->second.second, k_.orcs[a->second.second].ctaid, w, k_.orcs[w].ctaid);
            else if (b->second.first != cs)
              k_.fail("miu: warps %u and %u of ctaid %u name CTA slots %u and %u", b->second.second,
                      w, k_.orcs[w].ctaid, b->second.first, cs);
          }
        }
        tried_.erase(tag);   // a new memop under this tag forms again
        memop_[tag] = {s, m.payload, now_, m.tid};
        cmpl_row_[tag] = unsigned(get(m.payload, c.ooe_miu, "done_row"));   // OI-85
        order_.push_back(tag);
      }
    for (unsigned s = 0; s != kChans[c.rcu_miu].rate; ++s)
      while (has(c.rcu_miu, s)) {
        Receiver::Msg m = take(c.rcu_miu, s);
        const unsigned tag = unsigned(get(m.payload, c.rcu_miu, "rob_tag"));
        auto mo = memop_.find(tag);
        if (mo != memop_.end() && mo->second.discarded) {
          replay(tag, mo->second);   // a discarded memop's address: it ends here
          continue;
        }
        addr_[tag] = {s, m.payload, m.tid};
      }
    for (unsigned s = 0; s != kChans[c.ooe_ret].rate; ++s)
      while (has(c.ooe_ret, s)) {
        Receiver::Msg m = take(c.ooe_ret, s);
        const unsigned tag = unsigned(get(m.payload, c.ooe_ret, "rob_tag"));
        auto it = stores_.find(tag);
        if (it == stores_.end()) {
          k_.fail("miu: retire for rob tag %u, which holds no store", tag);
          continue;
        }
        if (get(m.payload, c.ooe_ret, "commit_or_discard")) {
          if (k_.brk == "drop-store" && !dropped_) { dropped_ = true; storeGone(it->second); }
          else committed_.push_back(it->second);
        } else {
          storeGone(it->second);
        }
        stores_.erase(it);
      }
    for (unsigned s = 0; s != kChans[c.dcu_miu].rate; ++s)
      while (has(c.dcu_miu, s)) {
        Receiver::Msg m = take(c.dcu_miu, s);
        // Matched by req_id, not by slot or arrival order: DCU may answer
        // four outstanding requests in any order.
        const unsigned id = unsigned(get(m.payload, c.dcu_miu, "req_id"));
        // A recovered UE is answered twice under one req_id. The first
        // answer's syndrome withholds the completion and the id stays live,
        // whatever owns it (a job, a window fill, a kill's drop, an orphan);
        // the second, from DCU's fill, is taken as the id's one answer.
        const bool ue = lineUe(m.payload, field(c.dcu_miu, "read_data").lsb,
                               field(c.dcu_miu, "check_bits").lsb);
        if (ue_first_.erase(id)) {
          if (ue || get(m.payload, c.dcu_miu, "hit"))
            k_.fail("miu: req_id %u's second answer after a UE is not a fill's (hit %u, UE %u; AR 370)",
                    id, unsigned(get(m.payload, c.dcu_miu, "hit")), unsigned(ue));
          k_.hit("ue_second_answer");
        } else if (ue && k_.brk != "ue-close-first") {
          ue_first_.insert(id);
          continue;
        }
        auto fl = fills_.find(id);
        if (fl != fills_.end()) {
          // A window fill: every slot its line holds (TI-31).
          Windows &t = win_[fl->second.cta];
          Line ln = getLine(m.payload, field(c.dcu_miu, "read_data").lsb);
          fixLine(ln, m.payload, field(c.dcu_miu, "check_bits").lsb);
          if (t.gen == fl->second.gen) fillWindows(t, fl->second.line, ln);
          fills_.erase(fl);
          ids_.release(id);
          continue;
        }
        if (k_.ue_withheld.count(id))
          k_.fail("miu: DCU answered req_id %u, a read a core-fatal UE withheld (AR 389)", id);
        if (kill_drop_.erase(id)) {   // a killed warp's read, completed at the kill
          ids_.release(id);
          continue;
        }
        auto orph = orphan_.find(id);
        if (orph != orphan_.end()) {
          // An orphan's response: dropped, no data, no completion (TI-21).
          const unsigned w = orph->second;
          orphan_.erase(orph);
          ids_.release(id);
          if (--orphans_[w] == 0 && k_.brk != "early-ready") ready(w);
          continue;
        }
        auto o = outstanding_.find(id);
        if (o == outstanding_.end()) {
          k_.fail("miu: a DCU response for req_id %u, which is not outstanding", id);
          continue;
        }
        const auto [serial, line] = o->second;
        outstanding_.erase(o);
        ids_.release(id);
        for (Job &j : jobs_)
          if (j.serial == serial) {
            // R2: the syndrome over the slot's code words, the line corrected.
            Line ln = getLine(m.payload, field(c.dcu_miu, "read_data").lsb);
            if (fixLine(ln, m.payload, field(c.dcu_miu, "check_bits").lsb)) j.ecc = true;
            j.got[line] = ln;
            if (!get(m.payload, c.dcu_miu, "hit")) j.hit = false;
            if (get(m.payload, c.dcu_miu, "mlc_miss")) j.mlc_miss = true;
            ++j.back;
          }
      }

    for (unsigned s = 0; s != kChans[c.spm_miu].rate; ++s)
      while (has(c.spm_miu, s)) {
        Receiver::Msg m = take(c.spm_miu, s);
        const unsigned id = unsigned(get(m.payload, c.spm_miu, "req_id"));
        auto orph = spm_orphan_.find(id);
        if (orph != spm_orphan_.end()) {
          const unsigned w = orph->second;
          spm_orphan_.erase(orph);
          spm_ids_.release(id);
          if (--orphans_[w] == 0 && k_.brk != "early-ready") ready(w);
          continue;
        }
        auto o = spm_out_.find(id);
        if (o == spm_out_.end()) {
          k_.fail("miu: an SPM response for req_id %u, which is not outstanding", id);
          continue;
        }
        const auto [serial, p] = o->second;
        spm_out_.erase(o);
        spm_ids_.release(id);
        if (get(m.payload, c.spm_miu, "conflict_serialization")) k_.hit("spm_wait");
        const Line rd = getLine(m.payload, field(c.spm_miu, "read_data").lsb);
        for (Job &j : jobs_)
          if (j.serial == serial) {
            // A load's lanes of this pass take their bytes, at their place
            // in the line, which is their bank's.
            for (unsigned l = 0; l != kLanes && !j.store; ++l)
              if ((j.active >> l & 1u) && j.lane_pass[l] == p) {
                Line &g = j.got[keyOf(j, l)];
                for (unsigned b = 0; b != j.bytes; ++b) g[offOf(j, l) + b] = rd[offOf(j, l) + b];
              }
            ++j.pback;
          }
      }

    // Every memop with its address starts (MA-4): misses and later passes
    // park in the memop queue, never in a pipe, so nothing caps the jobs in
    // flight but the queue's credits and DCU's req_ids.
    walkCycle();
    start();
    advance();
    // A hit's data leaves at the contract's data cycle and its completion
    // CCV_LAT_L1_ECC cycles later (AR 368, OA 426: the syndrome stages), or
    // not as a hit at all: if the data has no credit then, both go late and
    // OOE takes it for a miss (A-46), never a completion on time with its
    // data behind it. With no ECC stage the two leave together, as before.
    while (!timed_.empty() && timed_.front().at <= now_) {
      Timed t = timed_.front();
      timed_.pop_front();
      if (t.data_only) {                   // late-hit-data's data, behind
        to_rcu_.push_back(t.data);
        continue;
      }
      constexpr uint64_t kEcc = ccv::prov::kLatL1Ecc;
      if (t.at == now_ && free(c.miu_rcu, t.data.slot) &&
          (kEcc != 0 || free(c.miu_ooe, t.cmpl.slot))) {
        const bool ecc = t.ecc;
        if (ecc) {
          // The speculative data, one bit wrong, on time; the corrected
          // beat and its completion as a miss's (held_). The controls:
          // ecc-no-fix completes on time and never corrects; ecc-cmpl-on-time
          // corrects later but completes on time, so OOE keeps the
          // dependants that read the bad value.
          Q bad = t.data;
          flipLoadBit(bad.msg);
          send(c.miu_rcu, bad.slot, bad.msg, bad.tid);
          if (k_.brk == "ecc-no-fix") {
            late_faults_.push_back({now_ + kEcc, t.cmpl});
          } else if (k_.brk == "ecc-cmpl-on-time") {
            late_faults_.push_back({now_ + kEcc, t.cmpl});
            ecc_beats_.push_back({now_ + kEcc + 2, t.data});
          } else {
            held_.push_back({now_ + kEcc + 2, t.data, t.cmpl});
          }
          k_.hit("l1_ecc_fix");
          continue;
        }
        if (kEcc == 0) sendCmpl(t.cmpl.slot, t.cmpl.msg, t.cmpl.tid);
        else late_faults_.push_back({now_ + kEcc, t.cmpl});
        if (k_.brk == "late-hit-data")
          // The data a cycle behind its contract: dependants woken by the
          // contract read the register before the load lands.
          timed_.push_front({now_ + 1, t.data, t.cmpl, true});
        else
          send(c.miu_rcu, t.data.slot, t.data.msg, t.data.tid);
        k_.hit("l1_hit");
      } else {
        // Late: the data goes when it can, and the completion a cycle on,
        // past the contract. Queued for this cycle's drain, the completion
        // could leave in the contract cycle with its data still behind
        // (miu_rcu out of credit, miu_ooe not): OOE takes that for the hit
        // and its woken dependants read the register before the load lands
        // (AR 359 (4): coremark128priv's operand CHECKs).
        to_rcu_.push_back(t.data);
        late_faults_.push_back({now_ + ccv::prov::kLatL1Ecc + 1, t.cmpl});
        k_.hit("l1_late");
      }
    }

    for (auto it = late_faults_.begin(); it != late_faults_.end();)
      if (it->first <= now_) { to_ooe_.push_back(it->second); it = late_faults_.erase(it); }
      else ++it;
    for (auto it = ecc_beats_.begin(); it != ecc_beats_.end();)
      if (it->first <= now_) { to_rcu_.push_back(it->second); it = ecc_beats_.erase(it); }
      else ++it;
    for (auto it = held_.begin(); it != held_.end();)
      if (it->at <= now_) {
        to_rcu_.push_back(it->data);
        to_ooe_.push_back(it->cmpl);
        it = held_.erase(it);
      } else {
        ++it;
      }
    // A completion never leaves ahead of its load's data: OOE wakes the
    // load's dependants on it, hit or miss (OA-23), and they would read the
    // register before the load lands (AR 359 (4)). to_rcu_ drains first, so
    // data and completion may still leave together.
    auto dataQueued = [&](uint64_t tid) {
      for (const Q &q : to_rcu_) if (q.tid == tid) return true;
      return false;
    };
    auto drain = [&](std::deque<Q> &q, unsigned chan) {
      for (auto it = q.begin(); it != q.end();)
        if (free(chan, it->slot) && !(chan == c.miu_ooe && dataQueued(it->tid))) {
          if (chan == c.miu_ooe) sendCmpl(it->slot, it->msg, it->tid);
          else send(chan, it->slot, it->msg, it->tid);
          it = q.erase(it);
        } else
          ++it;
    };
    drain(to_fet_, c.miu_fet);
    drain(to_rcu_, c.miu_rcu);
    drain(to_ooe_, c.miu_ooe);
    drain(to_dcu_, c.miu_dcu);
    drain(to_rau_, c.miu_ready);
    if (!l0_.empty()) l0Refill();
    a1GateFlop();
    ids_.tick();
  }

  /// Whether rob_tag lies in a bulk discard's circular range (branch, tail]
  /// of the same ROB. branch == tail is the whole ROB: a squash to
  /// retirement of a full ROB, since a discard is never sent for an empty
  /// range.
  static bool inRange(unsigned tag, unsigned branch, unsigned tail) {
    const unsigned w = ccv::prov::kWRobIdx, d = 1u << w, mask = d - 1;
    if (tag >> w != branch >> w) return false;
    const unsigned b = branch & mask;
    const unsigned len = (tail - b) & mask;
    return ((tag & mask) - b - 1 & mask) < (len ? len : d);
  }

  /// A bulk discard (A-41; TI-21): the warp's stores in its range are
  /// dropped, and every memop in it that has not completed is completed now
  /// with status replay: one not started yet, or a load in flight, whose
  /// requests to DCU become orphans. A load whose completion is promised by
  /// a hint, or already on its way, completes as it would have: one
  /// completion either way.
  void discard(const Bits &m) {
    const Ch &c = ch();
    const unsigned w = unsigned(get(m, c.ooe_miu, "warp_id"));
    const unsigned branch = unsigned(get(m, c.ooe_miu, "rob_tag"));
    const unsigned tail =
        (branch & ~((1u << ccv::prov::kWRobIdx) - 1)) |
        unsigned(m.get(field(c.ooe_miu, "disp").lsb, ccv::prov::kWRobIdx));
    k_.hit("bulk_discard");
    for (auto it = stores_.begin(); it != stores_.end();)
      if (it->second.warp == w && inRange(it->first, branch, tail)) {
        storeGone(it->second);
        it = stores_.erase(it);
      }
      else ++it;
    std::vector<unsigned> now;
    for (unsigned tag : order_) {
      Memop &mo = memop_[tag];
      if (unsigned(get(mo.msg, c.ooe_miu, "warp_id")) != w || !inRange(tag, branch, tail)) continue;
      // An atomic's step finishes its pass, as OOE's does (atomFinishing).
      const unsigned amop = unsigned(get(mo.msg, c.ooe_miu, "mem_op"));
      if (amop == kMemAtomicRead || amop == kMemAtomicWrite) continue;
      if (addr_.erase(tag)) now.push_back(tag);
      else mo.discarded = true;   // ended by its address, which is on its way
    }
    for (unsigned tag : now) replay(tag, memop_[tag]);
    for (auto it = jobs_.begin(); it != jobs_.end();) {
      Job &j = *it;
      if (j.walk || j.store || j.atom || j.warp != w || j.promised || !inRange(j.tag, branch, tail)) { ++it; continue; }
      for (auto o = outstanding_.begin(); o != outstanding_.end();)
        if (o->second.first == j.serial) {
          orphan_[o->first] = w;
          ++orphans_[w];
          k_.hit("orphan");
          o = outstanding_.erase(o);
        } else {
          ++o;
        }
      for (auto o = spm_out_.begin(); o != spm_out_.end();)
        if (o->second.first == j.serial) {
          spm_orphan_[o->first] = w;
          ++orphans_[w];
          k_.hit("orphan");
          o = spm_out_.erase(o);
        } else {
          ++o;
        }
      if (k_.brk != "drop-replay") to_ooe_.push_back({j.memop_slot, replayMsg(j.tag, j.rs_idx), j.tid});
      if (k_.brk == "replay-twice") to_ooe_.push_back({j.memop_slot, cmpl(j), j.tid});
      k_.hit("replay");
      it = jobs_.erase(it);
    }
    // early-ready: reported at the discard, not when its orphans are home.
    if (!orphans_[w] || k_.brk == "early-ready") ready(w);
  }

  /// A memop not started, ended by a discard: its replay completion.
  void replay(unsigned tag, const Memop &mo) {
    const Ch &c = ch();
    // An atomic's step is never replayed (schema text; OA's response re:TI
    // rev 365): a bulk discard exempts it.
    const unsigned mop = unsigned(get(mo.msg, c.ooe_miu, "mem_op"));
    if (mop == kMemAtomicRead || mop == kMemAtomicWrite || atom_.count(tag))
      k_.fail("miu: rob tag %u, an atomic's step, completed with status replay", tag);
    if (k_.brk != "drop-replay")
      to_ooe_.push_back(
          {mo.slot, replayMsg(tag, unsigned(get(mo.msg, c.ooe_miu, "rs_idx"))), mo.tid});
    k_.hit("replay");
    order_.erase(std::find(order_.begin(), order_.end(), tag));
    tried_.erase(tag);
    memop_.erase(tag);
    win_miss_.erase(tag);
    lost_.erase(tag);
  }

  // The fault lead (OI-125; AR's rev 314, MIU spec rev 61): lead_fault is
  // status == 1, set as the completion leaves, with its valid a cycle ahead
  // of the payload; a replay or a complete one never sets it. --break
  // lead-fault-replay sets it on a replay too (OA rev 376's first rule,
  // status nonzero), and --break lead-fault-drop never sets it on a fault;
  // OOE's equality must refuse both.
  /// A completion to OOE, on the memop's arrival slot. Every memop gets
  /// exactly one (ccv_miu_ooe), so it frees the memop's queue entry, and so
  /// its credit (MA-5). An atomic's more = 1 is not a second completion of
  /// this memop: OOE re-issues the steps as new memops (AR-21).
  /// One bit of the lowest active lane's data flipped: what a single-bit
  /// error in the array leaves in the speculative data.
  void flipLoadBit(Bits &m) {
    const Ch &c = ch();
    const unsigned l = __builtin_ctz(uint32_t(get(m, c.miu_rcu, "active_mask")));
    putLane(m, c.miu_rcu, "load_data", l, getLane(m, c.miu_rcu, "load_data", l) ^ 1u);
  }

  void sendCmpl(unsigned slot, const Bits &m, uint64_t tid) {
    const Ch &c = ch();
    send(c.miu_ooe, slot, withLead(m), tid);
    if (ltrace_)
      std::fprintf(stderr, "LTRACE %llu cmpl tag %u\n", (unsigned long long)now_,
                   unsigned(get(m, c.miu_ooe, "rob_tag")));
    if (!entries_[slot]) {
      k_.fail("miu: a last completion on slot %u, which holds no memop entry", slot);
      return;
    }
    if (keep_.erase(tid)) return;   // a store's entry stays until its drain
    freeEntry(slot);
  }
  /// A memop's MQ entry freed, and its credit returned, unless a drain that
  /// has waited past N_drain claims the credit (MIU tab, the drain): it is
  /// withheld until that drain goes.
  void freeEntry(unsigned slot) {
    const Ch &c = ch();
    if (!entries_[slot]) {
      k_.fail("miu: an entry freed on slot %u, which holds none", slot);
      return;
    }
    --entries_[slot];
    for (auto &g : guard_)
      if (g.second < 0) {
        g.second = int(slot);
        k_.hit("drain_guard_withheld");
        return;
      }
    release(c.ooe_miu, slot);
  }
  /// A store's entry, when its life ends: discarded, or drained.
  void storeGone(const Job &j) {
    if (!j.entry) return;
    if (keep_.count(j.tid)) {
      // Its completion has not left yet: that frees the entry instead.
      keep_.erase(j.tid);
      return;
    }
    freeEntry(j.memop_slot);
  }
  std::set<uint64_t> keep_;             ///< stores whose completion keeps the entry
  // Translation (MIU tab, MA-8; Common tab rev 9): a 32-entry fully
  // associative TLB looked up in A2 on the memop's pages, and one walker,
  // shared with FET's ITLB, whose reads are DCU lookups on idle slots. Cold
  // at each kernel's start: the block is built per kernel. Translation is
  // the identity and a PTE's value is unused (AR 392), so a walk costs DCU
  // time and L1 capacity but never changes an address.
  /// CCV_MIU_TLB=cold: the TLB and walker as the MIU tab has them, cold at
  /// each kernel's start. Default warm: every page held, no walk, FET's
  /// ITLB answered at once, as the stub: a cold start moves every kernel's
  /// interleaving, which check-kernel's scenarios pin (open with MA).
  const bool tlb_on_ = [] {
    const char *v = std::getenv("CCV_MIU_TLB");
    return v && std::strcmp(v, "cold") == 0;
  }();
  miu::Tlb tlb_{miu::Pending::kTlbEntries};
  miu::Walker walker_{std::vector<unsigned>(std::begin(miu::Pending::kWalkBits),
                                            std::end(miu::Pending::kWalkBits)),
                      miu::Pending::kWalkBase, 16, miu::Pending::kPteBytes,
                      miu::Pending::kWalkExtra};
  bool walk_out_ = false;               ///< the walker's read is a job in flight
  std::map<uint64_t, uint64_t> walk_tid_;   ///< a page's walk, by the uid that asked first
  std::map<uint64_t, uint64_t> fet_tid_;    ///< FET's ITLB requests waiting on a walk
  std::set<unsigned> tlb_missed_;       ///< memops whose tlb_miss is counted
  /// A walk done: the data TLB filled, FET's refill sent.
  void walkDone() {
    const Ch &c = ch();
    const uint64_t vpn = walker_.doneVpn();
    const unsigned src = walker_.doneSrc();
    walk_tid_.erase(vpn);
    k_.hit("tlb_walk");
    if (src & miu::Walker::kData) tlb_.fill(vpn);
    if (src & miu::Walker::kItlb) {
      auto f = fet_tid_.find(vpn);
      Bits r = msgOf(c.miu_fet);
      put(r, c.miu_fet, "itlb_refill", vpn);
      to_fet_.push_back({0, r, f == fet_tid_.end() ? 0 : f->second});
      if (f != fet_tid_.end()) fet_tid_.erase(f);
      k_.hit("itlb_walk");
    }
  }
  /// One cycle of the walker: its read, once due, starts as a DCU lookup on
  /// an idle slot (advance() sends it after the first passes).
  void walkCycle() {
    walker_.cycle();
    uint64_t a = 0;
    if (walk_out_ || !walker_.wantRead(a)) return;
    // walk-no-dcu: each level done without its read.
    if (k_.brk == "walk-no-dcu") {
      walker_.sent();
      if (walker_.got()) walkDone();
      return;
    }
    k_.hit("walk_reads");
    Job w;
    w.walk = true;
    w.tag = ~0u;
    w.warp = ~0u;
    const auto t = walk_tid_.find(walker_.curVpn());
    w.tid = t == walk_tid_.end() ? 0 : t->second;
    LineReq lr{a / kLine * kLine};
    lr.sub = 0;
    w.lines.push_back(lr);
    walker_.sent();
    walk_out_ = true;
    launch(w);
  }

  std::map<unsigned, int> guard_;       ///< drain guard by store tag: withheld slot, -1 not yet
  std::map<unsigned, uint64_t> head_at_;   ///< when a committed store became its warp's head
  bool armed_ = false, at_entry_ = false;
  std::array<unsigned, 8> entries_{};   ///< queue entries held, by memop slot

  /// AR 362: the lookup's set index leads it, from the formed address
  /// (the stub's line is its leader's); its bank is the index's low bits
  /// (AR 364). --break dcu-set-lead sends a wrong one, which DCU must refuse
  /// by name.
  void putIndexLead(Bits &r, uint64_t pa) {
    put(r, ch().miu_dcu, "lead_set_index", indexLeadSet(pa) ^ (k_.brk == "dcu-set-lead" ? 1u : 0u));
    // MA-30, AR 405: A2's fold of the lookup's PA (TI's hook; MI's to own).
    put(r, ch().miu_dcu, "pa_fold", paFold(pa) ^ (k_.brk == "miu-fold-flip" ? 1u : 0u));
  }

  Bits withLead(Bits m) {
    const Ch &c = ch();
    const unsigned st = unsigned(get(m, c.miu_ooe, "status"));
    put(m, c.miu_ooe, "lead_fault",
        (st == kStatusFault && k_.brk != "lead-fault-drop") ||
            (st == kStatusReplay && k_.brk == "lead-fault-replay"));
    return m;
  }

  Bits replayMsg(unsigned tag, unsigned rs_idx) {
    const Ch &c = ch();
    Bits m = msgOf(c.miu_ooe);
    put(m, c.miu_ooe, "rob_tag", tag);
    put(m, c.miu_ooe, "done_row", cmpl_row_[tag]);   // OI-85
    put(m, c.miu_ooe, "rs_idx", rs_idx);
    put(m, c.miu_ooe, "status", kStatusReplay);
    return m;
  }

  void ready(unsigned w) {
    if (k_.brk == "no-ready") return;
    Bits r = msgOf(ch().miu_ready);
    put(r, ch().miu_ready, "warp_id", w);
    to_rau_.push_back({0, r, makeUid(IdClass::kNone, 0)});
  }

  /// Committed stores first (they are older than anything still issuing),
  /// then the oldest memop whose address has arrived.
  void start() {
    const Ch &c = ch();
    // The drain (MA-11): committed stores in commit order per warp, so each
    // warp's oldest is the one that may go, the oldest of those first. One
    // waits only while a write to one of its lines is in flight (DCU keeps
    // a line's requests in order, and st.pred's read-merge-write keeps its
    // line to itself) or an atomic's pass holds one; never for a read, so
    // another warp's loads, which never wait (MA-11), cannot starve it.
    {
      // A warp's head that has waited N_drain cycles withholds one memop
      // credit until it goes (guard_), so stores cannot starve under
      // full-rate issue.
      std::set<unsigned> seen;
      for (auto it = committed_.begin(); it != committed_.end(); ++it) {
        if (!seen.insert(it->warp).second) continue;
        const uint64_t since = head_at_.emplace(it->tag, now_).first->second;
        const bool waits = inFlight(*it, kAnyWrite) || held(*it);
        if (waits) {
          if (held(*it)) k_.hit("atomic_hold_wait");
          if (now_ - since >= miu::Pending::kDrainWait && !guard_.count(it->tag)) {
            guard_[it->tag] = -1;
            k_.hit("drain_guard");
          }
          continue;
        }
        head_at_.erase(it->tag);
        auto g = guard_.find(it->tag);
        if (g != guard_.end()) {
          if (g->second >= 0) release(c.ooe_miu, unsigned(g->second));
          guard_.erase(g);
        }
        Job cj = *it;
        committed_.erase(it);
        // A predicate store drains as a read-merge-write of its word (MIU
        // spec rev 25, O-63): its line read and held, then the merged word
        // written. With no lane in its mask, nothing is read or written.
        if (cj.pxfer) cj.rmw = 1;
        if (!(cj.pxfer && cj.lines.empty())) launch(cj);
        else storeGone(cj);
        break;
      }
    }
  memops:
    // An atomic's write (AR-21) goes first, wherever it lies in order_ once
    // its data has come: its pass holds lines a memop ahead of it may wait
    // on, so it must never wait behind one.
    for (unsigned t : order_)
      if (addr_.count(t) && get(memop_[t].msg, c.ooe_miu, "mem_op") == kMemAtomicWrite) {
        atomWrite(t);
        break;
      }
    // Every memop with its address, in issue order. tryStart() takes it out
    // of order_ when it starts, so iterate a copy.
    // A global load that waits at its A2 has lost the L1 contract for a
    // reason A2 knows, and says so early (MA-4's no-hit; MIU tab, ordering).
    const std::deque<unsigned> ready(order_);
    std::set<unsigned> held_warps;   // warps with an older load held at A2
    for (unsigned t : ready) {
      if (!addr_.count(t)) continue;
      const bool ld = contracted(t);
      const unsigned w = unsigned(get(memop_[t].msg, c.ooe_miu, "warp_id"));
      const bool was_lost = lost_.count(t) != 0;
      if (tryStart(t)) {
        // MI-3: a younger load passing its warp's held one (MA rev 123).
        if (ld && held_warps.count(w)) k_.hit("ld_pass_held");
        continue;
      }
      if (!memop_.count(t) || !ld) continue;
      held_warps.insert(w);
      if (was_lost) continue;
      lost_.insert(t);
      k_.hit("l1_held_lost");
      const Memop &mo = memop_[t];
      noHit(mo.at, mo.slot, t, unsigned(get(mo.msg, c.ooe_miu, "rs_idx")), addr_[t].tid);
    }
  }
  /// Memops that waited at A2: started later, never as hits.
  std::set<unsigned> lost_;
  /// Memops that have been through A1 and wait in the queue.
  std::set<unsigned> tried_;
  /// Whether memop `t` is a load under the L1-hit contract: .global, not a
  /// store, an atomic or a fence.
  bool contracted(unsigned t) {
    const Ch &c = ch();
    const Bits &m = memop_[t].msg;
    const unsigned op = unsigned(get(m, c.ooe_miu, "mem_op"));
    return get(m, c.ooe_miu, "space") == kSpaceGlobal &&
           (op == kMemLoad || op == kMemPredLoad);
  }

  /// One memop's A1/A2: its address, faults and eligibility, then its
  /// lookups or its wait. False: it waits (a window fill, a fence, an older
  /// store of its warp, an atomic's hold), and tries again next cycle.
  bool tryStart(unsigned tag) {
    const Ch &c = ch();
    auto a = addr_.find(tag);
    if (a == addr_.end()) return false;
    // A1 is once: a memop held at A2 tries again from its queue entry, and
    // a bin A1 reaches counts once a memop (tried_ marks it counted), on
    // whichever try first reaches it.
    // A fence not yet complete holds its warp's younger memops (IS-11):
    // they issued after it, in program order per warp (OI-15).
    {
      const unsigned w = unsigned(get(memop_[tag].msg, c.ooe_miu, "warp_id"));
      for (unsigned t : order_) {
        if (t == tag) break;
        const Bits &om = memop_[t].msg;
        if (get(om, c.ooe_miu, "mem_op") == kMemFence && unsigned(get(om, c.ooe_miu, "warp_id")) == w) {
          k_.hit("fence_hold");
          return false;
        }
      }
    }
    const Memop mo = memop_[tag];   // a copy: memop_[tag] is erased below (DI-9)
    // The launch-slot form (TI-31): its window must be in the table. If not,
    // the memop waits, and every one behind it, while its line is read: an
    // L1 miss, never a hit (AR's response). no-window-fill: the table is
    // taken as filled, its words zero.
    const bool slot = get(mo.msg, c.ooe_miu, "slot_form") != 0;
    // The interleaved local form (IS-19) takes local_base from the CTA's
    // ccv_rau_miu_cta (TI-47), so it never waits for the line.
    const bool local = get(mo.msg, c.ooe_miu, "local_form") != 0;
    const unsigned cta = unsigned(get(mo.msg, c.ooe_miu, "cta_slot"));
    const unsigned k = unsigned(get(mo.msg, c.ooe_miu, "arg_slot"));
    if (slot && k_.brk != "no-window-fill" && !(win_[cta].valid >> k & 1u)) {
      const uint64_t line = slotAddr(win_[cta], k) / kLine * kLine;
      win_miss_.insert(tag);
      for (const auto &f : fills_)
        if (f.second.cta == cta && f.second.line == line && f.second.gen == win_[cta].gen)
          return false;                                         // on its way
      // Its read needs its bank's entry credit (MA-25), as any lookup.
      if (!bankCan(bankOf(line), false)) {
        fill_held_.insert(tag);
        k_.hit("credit_hold");
        return false;
      }
      // One lookup a bank a cycle (MA-27; DCU's CHECK): the fill yields to
      // a bank this cycle's first passes or an earlier fill took, and
      // advance() keeps later passes off the fill's (wf_banks_; TI-544).
      if ((firstPassBanks() | wf_banks_) >> bankOf(line) & 1u) {
        k_.hit("window_fill_bank_wait");
        return false;
      }
      const uint32_t owned = firstPassSlots();
      for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s) {
        if ((owned >> s & 1u) || !free(c.miu_dcu, s)) continue;
        if (!ids_.any(s)) { idStall(s); continue; }
        bankTake(bankOf(line), false);
        wf_banks_ |= 1u << bankOf(line);
        if (fill_held_.erase(tag)) k_.hit("credit_hold_then_sent");
        Bits r = msgOf(c.miu_dcu);
        const unsigned id = ids_.take(s);
        put(r, c.miu_dcu, "req_id", id);
        put(r, c.miu_dcu, "phys_addr", line);
        putIndexLead(r, line);
        put(r, c.miu_dcu, "size", kSizeLine);
        put(r, c.miu_dcu, "coh_op", kCohRead);
        send(c.miu_dcu, s, r, makeUid(IdClass::kTxn, uidSeq(mo.tid), 0, /*owned=*/true));
        fills_[id] = {cta, line, win_[cta].gen};
        k_.hit("window_fill");
        k_.hit("dcu_lookups");
        break;
      }
      return false;
    }
    // A fence (IS-11): every older store of its warp written to DCU before
    // it completes, so what follows it, a barrier arrive among them (TI-40),
    // comes after those writes are visible to every warp. Memops arrive in
    // program order per warp, so the warp's stores still uncommitted here are
    // all older; one committed but not yet written waits in committed_ or in
    // flight. No kernel here can see a fence that does not wait: this MIU
    // also holds any load while a store to its line is in flight.
    if (get(mo.msg, c.ooe_miu, "mem_op") == kMemFence) {
      const unsigned w = unsigned(get(mo.msg, c.ooe_miu, "warp_id"));
      bool pending = false;
      for (const auto &st : stores_) pending = pending || st.second.warp == w;
      for (const Job &cj : committed_) pending = pending || cj.warp == w;
      for (const Job &f : jobs_) pending = pending || (f.store && f.warp == w);
      if (pending) { k_.hit("fence_wait"); return false; }
      Job f;
      f.tag = tag;
      f.warp = w;
      f.memop_slot = mo.slot;
      f.rs_idx = unsigned(get(mo.msg, c.ooe_miu, "rs_idx"));
      f.tid = a->second.tid;
      to_ooe_.push_back({f.memop_slot, cmpl(f), f.tid});
      order_.erase(std::find(order_.begin(), order_.end(), tag));
      tried_.erase(tag);
      memop_.erase(tag);
      addr_.erase(a);
      k_.hit("fence");
      return true;
    }
    Job j;
    j.tag = tag;
    const unsigned mop = unsigned(get(mo.msg, c.ooe_miu, "mem_op"));
    j.store = mop == kMemStore || mop == kMemPredStore;
    j.atom = mop == kMemAtomicRead ? 1u : 0u;
    j.pxfer = mop == kMemPredLoad || mop == kMemPredStore;
    j.memop_slot = mo.slot;
    j.warp = unsigned(get(mo.msg, c.ooe_miu, "warp_id"));
    j.phys_dst = unsigned(get(mo.msg, c.ooe_miu, "phys_dst"));
    j.phys_pred = unsigned(get(mo.msg, c.ooe_miu, "phys_pred"));
    j.rs_idx = unsigned(get(mo.msg, c.ooe_miu, "rs_idx"));
    j.dst_pos = unsigned(get(mo.msg, c.ooe_miu, "dst_pos"));
    j.chw = unsigned(get(mo.msg, c.ooe_miu, "chwidth"));
    j.xsize = unsigned(get(mo.msg, c.ooe_miu, "xfer_size"));
    j.xsigned = get(mo.msg, c.ooe_miu, "xfer_signed") != 0;
    j.addr_slot = a->second.slot;
    j.tid = a->second.tid;
    // The L1 contract (A-46, A-61): a hit's completion reaches OOE at its
    // issue + CCV_LAT_L1_CMPL. The memop's arrival says when OOE issued it,
    // since it left on that cycle and the link is fixed, so the completion
    // must leave MIU CCV_LAT_L1_CMPL less both crossings after it arrived.
    // Timed from the issue, not from when MIU got to it: a load MIU starts
    // late cannot be a hit, and one whose address came early is not early.
    j.due = mo.at + ccv::prov::kLatL1Cmpl - crossing(c.ooe_miu) - crossing(c.miu_ooe) -
            (k_.brk == "early-hit" ? 1 : 0);
    const Bits am = a->second.msg;   // a copy: addr_ is erased below (DI-9)
    // Two DIFFERENT masks: the issue mask from OOE, and active = issue AND
    // guard from RCU. They differ for any predicated op, correctly; what
    // must hold is that no lane is active outside the issue group.
    j.active = uint32_t(get(am, c.rcu_miu, "active_mask"));
    const uint32_t issue = uint32_t(get(mo.msg, c.ooe_miu, "issue_mask"));
    // The AGU (§5.1): .global is (base << 16) + (index << scale) + disp, and
    // the scale is log2 of the element size, from chwidth, when enabled.
    // .shared has no window shift. disp is sign-extended from CCV_W_DISP.
    const FieldDesc &df = field(c.ooe_miu, "disp");
    const uint64_t draw = get(mo.msg, c.ooe_miu, "disp");
    const int64_t disp = int64_t(draw << (64 - df.width)) >> (64 - df.width);
    const unsigned chw = unsigned(get(mo.msg, c.ooe_miu, "chwidth"));
    // O-80: a sized form's transfer is its opcode's, else rdata's width;
    // the scale, alignment and bytes moved all follow the transfer.
    // xfer-ignored: the transfer taken from rdata's width alone.
    const unsigned xs = k_.brk == "xfer-ignored" ? 0u : j.xsize;
    const unsigned nb = k_.brk == "wide-xfer" ? 4u : xs == 1 ? 1u : xs == 2 ? 2u : spanOf(chw);
    j.bytes = nb;
    const unsigned sh = get(mo.msg, c.ooe_miu, "scale_en") ? (nb == 4 ? 2u : nb == 2 ? 1u : 0u) : 0;
    const bool global = get(mo.msg, c.ooe_miu, "space") == kSpaceGlobal;
    j.global = global;
    // The base is per lane (TI-32), or a launch slot's window (TI-31).
    // window-from-base: a slot form's window taken from base_per_lane.
    if (win_miss_.count(tag)) j.hit = false;
    const bool from_win = slot && k_.brk != "window-from-base";
    if (slot && tried_.insert(tag).second) k_.hit("slot_form");
    // O-69's address (IS-19): lane l's byte b of the warp's spill frame is
    // ((local_base + CCV_LANE_CONTEXTS) << 16) + (ctx << 22) + 128 (b / 4)
    // + 4l + b % 4, ctx the warp's hardware context, which MIU forms from
    // the memop's warp_id and its core's index (OA's proposal IS-19).
    // local-no-ctx: ctx taken as 0, so every warp spills to one frame.
    // local-base-slot: local_base taken from the wrong word, launch slot 0's,
    // which is 0 here.
    const uint64_t lbase = k_.brk == "local-base-slot" ? 0 : lbase_[cta];
    const uint64_t ctx = k_.brk == "local-no-ctx"
                             ? 0 : (uint64_t(ccv::prov::kCoreId) << ccv::kWWarpId) | j.warp;
    auto localAddr = [&](uint64_t b, unsigned l) {
      return ((lbase + ccv::prov::kLaneContexts) << 16) + (ctx << 22) + 128 * (b / 4) + 4 * l + b % 4;
    };
    // A predicate transfer has one address, lane 0's base whether or not
    // lane 0 is active (O-62), and moves a predicate's word: every active
    // lane names it, so F-RO's lanes and a fault's are the issue mask's.
    // xfer-low-lane: the lowest active lane's base, the slot that moves
    // when a group splits.
    if (j.pxfer) {
      const unsigned bl = k_.brk == "xfer-low-lane" && j.active ? __builtin_ctz(j.active) : 0;
      // In the local form, warp-scoped: the formula's address with l = 0.
      const uint64_t a =
          local ? localAddr(uint64_t(disp), 0)
                : (uint64_t(getLane(am, c.rcu_miu, "base_per_lane", bl)) << (global ? 16 : 0)) +
                      uint64_t(disp);
      for (unsigned l = 0; l != kLanes; ++l)
        if ((j.active >> l) & 1u) j.addr[l] = a;
      j.pdata = getLane(am, c.rcu_miu, "store_data", 0);
    }
    for (unsigned l = 0; l != kLanes && !j.pxfer; ++l)
      if ((j.active >> l) & 1u && local) {
        j.addr[l] = localAddr(uint64_t(disp), l);
      } else if ((j.active >> l) & 1u) {
        const uint64_t b = from_win ? uint64_t(win_[cta].w[k])
                                    : uint64_t(getLane(am, c.rcu_miu, "base_per_lane", l));
        j.addr[l] = (b << (global ? 16 : 0)) +
                    (uint64_t(getLane(am, c.rcu_miu, "index_per_lane", l)) << sh) +
                    uint64_t(disp);
      }
    // O-83 (option W, DA tab rev 95; ISA section 5.9): a .global access in a
    // form that takes rbase is interleaved when lane d's rbase lies in the
    // private run, d the lowest lane of the ISSUE mask whether or not its
    // predicate is set. W = local_base + %privoff, local_base from the CTA's
    // ccv_rau_miu_cta (TI-47). Each lane's offset b is its own, from
    // its own rbase; lane l's byte b is at R(ctx) + 128 (b / 4) + 4l + b % 4,
    // past the run's own windows, and b outside [0, L) is F-ADDR, as is an
    // ordinary access into the run's own windows, which name logical offsets
    // only. ld.pred/st.pred: lane d's b with l = 0. The launch-slot and
    // local forms, and .shared, are never interleaved.
    // priv-lane0: the decision on lane 0's rbase (ccv-sim's
    // -ccv-test-priv-lane0), which a diverged group with lane 0 off gets wrong.
    // priv-no-ctx: R(ctx) taken at ctx 0, so every warp shares one region.
    uint32_t pbad = 0;
    if (global && issue) {
      const uint64_t W = lbase_[cta] + 3ull * ccv::prov::kLaneContexts;
      const unsigned pk = unsigned(__builtin_ctz(ccv::prov::kPrivWindows));
      const int64_t L = int64_t(ccv::prov::kPrivWindows) << 16;
      const unsigned d = k_.brk == "priv-lane0" ? 0u : unsigned(__builtin_ctz(issue));
      const uint64_t rbd = getLane(am, c.rcu_miu, "base_per_lane", d);
      if (!slot && !local && (rbd >> pk) == (W >> pk)) {
        const uint64_t pctx = k_.brk == "priv-no-ctx" ? 0 : ctx;
        const uint64_t R = ((W + ccv::prov::kPrivWindows) << 16) + pctx * 32 * uint64_t(L);
        auto bOf = [&](unsigned l, bool idx) {
          const int64_t rb = int64_t(getLane(am, c.rcu_miu, "base_per_lane", l));
          const int64_t ix = idx ? int64_t(uint64_t(getLane(am, c.rcu_miu, "index_per_lane", l)) << sh) : 0;
          return ((rb - int64_t(W)) << 16) + ix + disp;
        };
        auto cell = [&](int64_t b, unsigned l) {
          return R + 128 * uint64_t(b / 4) + 4 * uint64_t(l) + uint64_t(b % 4);
        };
        const int64_t bd = bOf(d, false);
        for (unsigned l = 0; l != kLanes; ++l) {
          if (!((j.active >> l) & 1u)) continue;
          const int64_t b = j.pxfer ? bd : bOf(l, true);
          if (b < 0 || b >= L) pbad |= 1u << l;
          else j.addr[l] = cell(b, j.pxfer ? 0u : l);
        }
        if (tried_.insert(tag).second) k_.hit("priv_form");
      } else {
        for (unsigned l = 0; l != kLanes; ++l)
          if ((j.active >> l & 1u) && !local && (j.addr[l] >> 16 >> pk) == (W >> pk)) pbad |= 1u << l;
      }
    }
    // .shared (CP-33): the offset into the CTA's region, modulo 2^32, which
    // ccv-sim names; SPM's byte address is the region's first byte plus it.
    // An SPM access is never an L1 hit. ccv-sim keeps the carry (task: CP-33),
    // so no kernel here crosses 2^32.
    j.spm = !global;
    if (j.spm) {
      j.hit = false;
      const auto sp = spm_.find(cta);
      const uint64_t sbase = sp == spm_.end() ? 0 : sp->second.first;
      for (unsigned l = 0; l != kLanes; ++l)
        if ((j.active >> l) & 1u) {
          j.addr[l] &= 0xffffffffu;
          j.paddr[l] = sbase + j.addr[l];
        }
    }
    // Lines touched by ACTIVE lanes, in first-touch order; each lane moves
    // the transfer above (AR-24 (d): its data register's width, 4, 2 or 1
    // bytes, or O-80's sized form's). An inactive lane's address is never
    // looked at. wide-xfer: every access moves four bytes, as the
    // 32-bit-only stubs did.
    std::map<uint64_t, size_t> at;
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!((j.active >> l) & 1u)) continue;
      // one-line: MIU takes the warp's access to lie in the line its first
      // active lane falls in, so the lanes past a line boundary are wrong.
      const uint64_t line = k_.brk == "one-line" && !j.lines.empty() ? j.lines[0].line : keyOf(j, l);
      if (!at.count(line)) {
        at[line] = j.lines.size();
        j.lines.push_back({line, {}, {}, uint16_t(j.lines.size())});
      }
      if (j.store && !j.pxfer) {   // a predicate store's word lands at its drain's merge
        LineReq &lr = j.lines[at[line]];
        const uint32_t v = getLane(am, c.rcu_miu, "store_data", l);
        for (unsigned b = 0; b != nb; ++b) {
          const unsigned off = offOf(j, l) + b;
          lr.data[off] = uint8_t(v >> (8 * b));
          lr.mask[off] = true;
        }
      }
    }
    // MA-27 (AR 400): A1 launches a contracted load's leader lookups, one a
    // group on the footprint's slots, before A2 knows whether they stand;
    // A2 sets drop on those it finds a TLB miss, a fault, a page split, a
    // lane off its leader's line, a bank conflict or a duplicate leader on
    // (dropAll, planFirstPass). Only on the load's first A1 (lost_ marks a
    // retry). Holds A1 knows from flopped state (a write in flight, an
    // atomic's hold, a fence) launch nothing; an older store's overlap,
    // found at A2, drops them (drop_held; MI-19 (3c), MA rev 147).
    std::vector<std::pair<unsigned, uint64_t>> leads;
    if (!j.store && !j.atom && j.global && j.active && contracted(tag) && !lost_.count(tag))
      leads = leadersOf(j, unsigned(get(memop_[tag].msg, c.ooe_miu, "pipes")));
    auto dropAll = [&](const char *why) {
      for (const auto &[s, line] : leads) drops_.push_back({now_ + 1, s, line, j.tid, why});
      leads.clear();
    };
    // A load waits, and every memop behind it, while a write of its warp to
    // one of its lines is in flight (MA-11: own warp only; DCU keeps a
    // line's requests in arrival order, so another warp's write needs none).
    if (!j.store && inFlight(j, kOwnWrite)) return false;   // (MI-19: no drop launched)
    // It also waits while an OLDER store of its warp to one of its lines
    // has not committed (MIU's disambiguation, MIU spec): this MIU forwards
    // nothing, so the load reads the line once the store's write has
    // landed. Memops issue in program order per warp (OI-15), so every
    // older store is already here; a younger one's write the load must not
    // see, and is not waited for (spinwait: lane 0's flag load behind lane
    // 1's store; AR's response TI-27 (d)).
    // no-st-wait: the load reads past the older store, and sees the flag
    // still clear.
    if (!j.store && k_.brk != "no-st-wait" && olderStore(j)) {
      // Found at A2 from this load's address, after A1 launched its
      // lookups: they drop (MI-19 (3c), MA rev 147). The holds above and
      // below come from flopped state A1 reads, and launch nothing.
      dropAll("drop_held");
      k_.hit("st_ld_wait");
      return false;
    }
    // And while an atomic's pass holds one of its lines (V-72). A store
    // waits at its drain.
    if (!j.store && held(j)) { k_.hit("atomic_hold_wait"); return false; }
    // A2's TLB (MA-8), under CCV_MIU_TLB=cold: every page the active lanes
    // touch must be held; a page that is not starts a walk and the memop
    // waits in its queue entry (a contracted load loses its contract:
    // start() sends its no-hit). Before any bin counts, so a retry counts
    // nothing twice. A memop with a faulting lane (F-ADDR, the private
    // run's) never walks: its fault comes first. No .global address may fall
    // in the page tables (Common tab rev 9).
    bool two_page = false;
    if (tlb_on_ && j.global && j.active && !pbad) {
      std::set<uint64_t> pages;
      bool faults = false;
      for (unsigned l = 0; l != kLanes; ++l)
        if (j.active >> l & 1u) {
          const uint64_t va = j.addr[l];
          if (va >> ccv::kAddrBits) faults = true;
          if (va >= miu::Pending::kWalkBase && va - miu::Pending::kWalkBase < walker_.span())
            k_.fail("miu: rob tag %u lane %u's address %llx lies in the page tables", tag, l,
                    (unsigned long long)va);
          pages.insert(va >> 16);
        }
      bool missing = false;
      // walk-before-faddr: the fault's pages walked first, as if F-ADDR came
      // after translation; a page past the 48-bit VA then reaches the walker.
      if (!faults || k_.brk == "walk-before-faddr")
        for (uint64_t vpn : pages)
          if (!tlb_.holds(vpn)) {
            if (vpn >> (ccv::kAddrBits - 16))
              k_.fail("miu: rob tag %u walks page %llx, past the 48-bit VA (F-ADDR comes first)",
                      tag, (unsigned long long)vpn);
            missing = true;
            walk_tid_.emplace(vpn, a->second.tid);
            walker_.request(vpn, miu::Walker::kData);
          }
      if (missing) {
        if (tlb_missed_.insert(tag).second) k_.hit("tlb_miss");
        dropAll("drop_tlb");
        return false;
      }
      if (!faults) for (uint64_t vpn : pages) tlb_.lookup(vpn);
      if (faults && k_.brk == "walk-before-faddr")
        for (uint64_t vpn : pages) if (!tlb_.holds(vpn)) return false;
      tlb_missed_.erase(tag);
      two_page = !faults && pages.size() > 1;
      if (two_page) k_.hit("tlb_two_page");
    }
    if (j.active & ~issue)
      k_.fail("miu: rob tag %u has active lanes %08x outside its issue group",
              tag, j.active & ~issue);
    check(j, am);
    if (j.spm && !j.atom) formPasses(j, am);   // an atomic's, by its pass
    if (j.pxfer) k_.hit("pred_xfer");
    if (local) k_.hit("local_form");
    if (j.lines.size() > 1) k_.hit("line_split");
    // AR-23's measure: an access whose active lanes lie in more than one
    // 64 KiB window, as every O-30 frame access does.
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l & 1u) && j.global &&
          j.addr[l] >> 16 != j.addr[__builtin_ctz(j.active)] >> 16)
        j.frame = true;
    k_.peak("lines_peak", j.lines.size());
    if (j.store)
      for (const LineReq &lr : j.lines)
        if (std::count(lr.mask.begin(), lr.mask.end(), true) != int(kLine)) k_.hit("partial_line");
    // F-ADDR (O-75): a .global address is the exact sum, never wrapped, and
    // one outside [0, 2^48) maps nothing; per lane, after F-ALIGN and before
    // F-RO, so where any lane has it, it is the instruction's cause (section
    // 12.5). addr-wrap: the sum taken modulo 2^48, so nothing faults.
    uint32_t bad = 0;
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l & 1u) && j.global && j.addr[l] >> ccv::kAddrBits && k_.brk != "addr-wrap")
        bad |= 1u << l;
    if (pbad) k_.hit("priv_fault");
    bad |= pbad;
    // F-SHARED (section 12.5): a .shared access with a byte past its CTA's
    // region, after F-ADDR, which no .shared access raises. ccv-sim bounds
    // no .shared access, so no kernel here can reach it yet.
    uint32_t sbad = 0;
    if (j.spm) {
      const auto sp = spm_.find(cta);
      const uint64_t size = sp == spm_.end() ? 0 : sp->second.second - sp->second.first + 1;
      for (unsigned l = 0; l != kLanes; ++l)
        if ((j.active >> l & 1u) && (j.pxfer ? 4u : j.bytes) + j.addr[l] > size) sbad |= 1u << l;
    }
    const uint32_t fl = bad ? bad : sbad;
    const uint32_t ro = fl ? 0u : roLanes(j, unsigned(get(mo.msg, c.ooe_miu, "cta_slot")));
    order_.erase(std::find(order_.begin(), order_.end(), tag));
    tried_.erase(tag);
    memop_.erase(tag);
    win_miss_.erase(tag);
    addr_.erase(a);
    if (fl) {
      dropAll("drop_fault");
      // As F-RO's: no lane has any effect, and the completion is the fault,
      // with the lowest faulting lane's address in full (section 12.6).
      Bits m = cmpl(j);
      put(m, c.miu_ooe, "status", kCmplFault);
      put(m, c.miu_ooe, "cause", bad ? kFaultAddr : kFaultShared);
      put(m, c.miu_ooe, "lane_mask", fl);
      put(m, c.miu_ooe, "address", j.addr[__builtin_ctz(fl)]);
      // A load's completion never comes before the L1 contract's cycle (A-46,
      // V-44), a fault's included: OOE would have woken nothing on it, and
      // takes an early one for a broken contract.
      if (!j.store && j.due > now_) late_faults_.push_back({j.due, {j.memop_slot, m, j.tid}});
      else to_ooe_.push_back({j.memop_slot, m, j.tid});
      k_.hit(bad ? "addr_fault" : "shared_fault");
      return true;
    }
    if (ro) {
      // F-RO: the store has no effect on any lane, so nothing waits for
      // retirement. The completion is the fault: its lanes, and the lowest
      // one's address (section 12.6). OOE takes it at retirement.
      Bits m = cmpl(j);
      put(m, c.miu_ooe, "status", kCmplFault);
      put(m, c.miu_ooe, "cause", kFaultRo);
      put(m, c.miu_ooe, "lane_mask", ro);
      put(m, c.miu_ooe, "address", j.addr[__builtin_ctz(ro)]);
      to_ooe_.push_back({j.memop_slot, m, j.tid});
      k_.hit("ro_fault");
      return true;
    }
    if (j.atom) { atomRead(j, am); return true; }
    if (j.store) {
      // Translated and checked; the write waits for retirement. Its
      // completion leaves now, but its MQ entry stays until it drains or
      // is discarded (MIU tab: committed stores throttle new memops).
      j.entry = true;
      keep_.insert(j.tid);
      stores_[tag] = j;
      to_ooe_.push_back({j.memop_slot, cmpl(j), j.tid});
      return true;
    }
    j.issue_at = mo.at;
    if (lost_.erase(tag)) {
      // It waited at A2: the contract went then, with its no-hit (start()).
      j.hit = false;
      j.inelig = true;
    } else if (j.global && j.active) {
      const char *why = eligibility(j, mo);
      if (ltrace_)
        std::fprintf(stderr, "LTRACE %llu a2 tag %u issue %llu %s\n", (unsigned long long)now_, tag,
                     (unsigned long long)mo.at, why ? why : "elig");
      if (why) dropAll(why);
      // Lanes over two pages leave the hit path (MIU tab, translation).
      // two-page-hit: such a load keeps its contract.
      if (!j.inelig && two_page && k_.brk != "two-page-hit") {
        loseFirstPass(j, "tlb_two_page_lost");
        dropAll("drop_split");
      }
      if (!j.inelig) planFirstPass(j, unsigned(get(mo.msg, c.ooe_miu, "pipes")));
    }
    launch(j);
    return true;
  }

  /// MA-4's eligibility for the L1-hit contract (MIU tab, MA's Phase 1
  /// draft; AR 356): a global load keeps it only if every active lane's
  /// line is its group's leader's, the access stays in one page, and its
  /// leaders' lookups meet no bank conflict (DCU's CCV_DCU_BANKS banks by
  /// the line address's low bits, [9:7] at 8; AR 364); a tag miss is not known from the address, and stays the
  /// contract's miss. The memop's F pipes split the warp into F groups of
  /// 32/F consecutive lanes, a group's leader its lowest active lane. A
  /// load that loses it is never an L1 hit, and A2 says so early: a no-hit
  /// on ccv_miu_ooe_cmpl_hint, payload at I + CCV_LAT_L1_NOHIT, on the
  /// memop's slot (OA 410, MA 56). no-nohit: none is sent, so l1_nohit is
  /// never reached.
  const char *eligibility(Job &j, const Memop &mo) {
    const Ch &c = ch();
    const unsigned pipes = unsigned(get(mo.msg, c.ooe_miu, "pipes"));
    const unsigned f = pipes ? unsigned(__builtin_popcount(pipes)) : 1u;
    const unsigned per = kLanes / f;
    const uint64_t page = j.addr[__builtin_ctz(j.active)] >> ccv::kLPageShift;
    std::vector<uint64_t> leads;
    const char *why = nullptr;   // the drop's cause, the first found
    for (unsigned g = 0; g != f; ++g) {
      bool have = false;
      uint64_t lead = 0;
      for (unsigned l = g * per; l != (g + 1) * per; ++l) {
        if (!(j.active >> l & 1u)) continue;
        const uint64_t line = keyOf(j, l);
        if (j.addr[l] >> ccv::kLPageShift != page && !why) why = "drop_split";
        if (!have) {
          have = true;
          lead = line;
          if (lead_pos_ && l != g * per && !why) why = "drop_lead_pos";
          if (std::find(leads.begin(), leads.end(), line) == leads.end()) leads.push_back(line);
        } else if (line != lead && !why) {
          why = "drop_line";
        }
      }
    }
    for (size_t a = 0; a != leads.size(); ++a)
      for (size_t b = a + 1; b != leads.size(); ++b)
        if ((leads[a] / kLine) % ccv::kDcuBanks == (leads[b] / kLine) % ccv::kDcuBanks && !why)
          why = "drop_bank";
    // MI-30 pricing (MA rev 198): CCV_MIU_L0=n, an n-entry L0 TLB per lookup
    // slot at A2, the 32-entry TLB behind it at A3. A leader's page missing
    // from its slot's L0 drops the first pass (drop_l0); A3 fills the L0.
    if (!l0_.empty() && !why) {
      unsigned slot_bits = pipes ? pipes : 1u;
      for (unsigned g = 0; g != f; ++g) {
        const unsigned slot = unsigned(__builtin_ctz(slot_bits));
        slot_bits &= slot_bits - 1;
        const uint32_t grp = uint32_t((uint64_t(1) << per) - 1) << (g * per);
        if (!(j.active & grp)) continue;
        pbin("l0_lookup");
        if (!l0_[slot].lookup(page)) {
          pbin("l0_miss");
          // The refill, as rtl/miu/miu_tlb.sv: pending from A2's flop, granted
          // two cycles on through CCV_MIU_TLB_PORTS read ports (default 4)
          // shared by the slots, the L0 entry readable three cycles after.
          bool queued = false;
          for (const L0Fill &q : l0_q_) queued = queued || (q.slot == slot && q.page == page);
          for (const L0Fill &q : l0_w_) queued = queued || (q.slot == slot && q.page == page);
          if (!queued) l0_q_.push_back({now_ + 2, slot, page});
          if (!why) why = "drop_l0";
        }
      }
    }
    if (!why) return nullptr;
    j.inelig = true;
    j.hit = false;
    k_.hit("l1_inelig");
    noHit(mo.at, mo.slot, j.tag, j.rs_idx, j.tid);
    return why;
  }
  /// Every group's leader lookup A1 launches for a contracted load (MA-4's
  /// first pass, before A2 deduplicates or drops any): (slot, line) for
  /// each group with an active lane, its lowest one's line.
  std::vector<std::pair<unsigned, uint64_t>> leadersOf(const Job &j, unsigned pipes) const {
    std::vector<std::pair<unsigned, uint64_t>> v;
    const unsigned f = pipes ? unsigned(__builtin_popcount(pipes)) : 1u;
    const unsigned per = kLanes / f;
    unsigned slot_bits = pipes ? pipes : 1u;
    for (unsigned g = 0; g != f; ++g) {
      const unsigned slot = unsigned(__builtin_ctz(slot_bits));
      slot_bits &= slot_bits - 1;
      const uint32_t grp = uint32_t((uint64_t(1) << per) - 1) << (g * per);
      if (j.active & grp) v.push_back({slot, keyOf(j, unsigned(__builtin_ctz(j.active & grp)))});
    }
    return v;
  }
  /// The early no-hit (MA-4): payload at I + CCV_LAT_L1_NOHIT on the
  /// memop's slot of ccv_miu_ooe_cmpl_hint. no-nohit: none is sent.
  void noHit(uint64_t mo_at, unsigned slot, unsigned tag, unsigned rs_idx, uint64_t tid) {
    const Ch &c = ch();
    if (k_.brk == "no-nohit") return;
    const uint64_t issue = mo_at - crossing(c.ooe_miu);
    const uint64_t at = issue + ccv::prov::kLatL1Nohit - crossing(c.cmpl_hint);
    if (at <= now_) {   // MIU reached it too late to say so in time
      k_.hit("l1_nohit_drop");
      return;
    }
    Bits m = msgOf(c.cmpl_hint);
    put(m, c.cmpl_hint, "rs_idx", rs_idx);
    put(m, c.cmpl_hint, "rob_tag", tag);
    put(m, c.cmpl_hint, "no_hit", 1);
    hints_.push_back({at, {slot, m, tid}, true, tag});
  }

  /// A .shared access's passes (TI's rev 230): each active lane, in
  /// ascending order, joins the first pass whose bank for it is free or
  /// already holds its word, so a pass is at most one word a bank and lanes
  /// naming one word share it. A store's bytes go in its pass by bank, the
  /// highest lane last, as ccv-sim writes them. Its lines stay as DCU's
  /// would be, keyed apart, and need no request: they mark it done.
  /// spm-one-pass: every lane in pass 0, a bank's last word taken for all.
  void formPasses(Job &j, const Bits &am) {
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!((j.active >> l) & 1u)) continue;
      const uint64_t w = j.paddr[l] / 4;
      const unsigned bank = unsigned(w % ccv::kSpmBanks);
      const uint16_t bw = uint16_t(w / ccv::kSpmBanks);
      size_t p = 0;
      if (k_.brk != "spm-one-pass")
        while (p != j.passes.size() && j.passes[p].used[bank] && j.passes[p].word[bank] != bw) ++p;
      if (p == j.passes.size()) j.passes.emplace_back();
      Job::Pass &ps = j.passes[p];
      ps.used[bank] = true;
      ps.word[bank] = bw;
      j.lane_pass[l] = uint8_t(p);
      const uint32_t v = j.store ? getLane(am, ch().rcu_miu, "store_data", l) : 0;
      for (unsigned b = 0; b != j.bytes; ++b) {
        const unsigned off = offOf(j, l) + b;
        if (j.store) ps.data[off] = uint8_t(v >> (8 * b));
        ps.mask[off] = true;
      }
    }
    j.next = j.back = unsigned(j.lines.size());
    for (LineReq &l : j.lines) l.sent = true;
    if (j.passes.size() > 1) k_.hit("spm_conflict");
    k_.peak("spm_passes_peak", j.passes.size());
  }

  /// An atomic's read (AR-21), translated and checked: its pass, the lowest
  /// lane left of each address, read with ownership (DCU's AcquireData) and
  /// held until its write is acked. A later pass's read is the same memop
  /// again, re-issued by OOE; its lanes come from what is left.
  /// atom-one-pass: every lane left in one pass, so lanes naming one
  /// address all read the value before any of them writes.
  /// atom-descending: the highest lane of each address first, the order the
  /// ISA rules out; only atomf's rounding tells it apart.
  void atomRead(Job j, const Bits &am) {
    auto it = atom_.find(j.tag);
    if (it == atom_.end()) {
      Atom a;
      a.addr = j.addr;
      a.paddr = j.paddr;
      a.left = j.active;
      a.global = j.global;
      a.spm = j.spm;
      a.warp = j.warp;
      a.bytes = j.bytes;
      it = atom_.emplace(j.tag, a).first;
      k_.hit("atomic");
    }
    Atom &a = it->second;
    // atom-descending: the highest lane left of each address goes first.
    const bool desc = k_.brk == "atom-descending";
    uint32_t pass = 0;
    for (unsigned i = 0; i != kLanes; ++i) {
      const unsigned l = desc ? kLanes - 1 - i : i;
      if (!(a.left >> l & 1u)) continue;
      bool dup = false;
      for (unsigned m = 0; m != kLanes && k_.brk != "atom-one-pass"; ++m)
        dup = dup || (m != l && (pass >> m & 1u) &&
                      (j.spm ? j.paddr[m] == j.paddr[l] : j.addr[m] == j.addr[l]));
      if (!dup) pass |= 1u << l;
    }
    if (a.passes++) k_.hit("atomic_repass");
    a.pass = pass;
    j.active = pass;
    j.hit = false;   // never the L1 contract (A-46)
    j.lines.clear();
    a.held.clear();
    for (unsigned l = 0; l != kLanes; ++l)
      if (pass >> l & 1u) {
        const uint64_t line = keyOf(j, l);
        if (std::find(a.held.begin(), a.held.end(), line) == a.held.end()) {
          a.held.push_back(line);
          j.lines.push_back({line, {}, {}, uint16_t(j.lines.size())});
        }
      }
    if (j.spm) formPasses(j, am);
    launch(j);
  }

  /// An atomic's write (AR-21): the pass's new values, from A2 by RCU's
  /// store_data, to the lines its read holds, checked against ccv-sim's
  /// writes. Its ack completes it, with more while lanes are left.
  void atomWrite(unsigned tag) {
    const Ch &c = ch();
    const Memop mo = memop_[tag];
    const auto ad = addr_.find(tag);
    const Bits am = ad->second.msg;
    Job j;
    j.tag = tag;
    j.tid = ad->second.tid;
    order_.erase(std::find(order_.begin(), order_.end(), tag));
    tried_.erase(tag);
    memop_.erase(tag);
    addr_.erase(ad);
    j.memop_slot = mo.slot;
    j.addr_slot = 0;
    j.warp = unsigned(get(mo.msg, c.ooe_miu, "warp_id"));
    j.rs_idx = unsigned(get(mo.msg, c.ooe_miu, "rs_idx"));
    const auto st = atom_.find(tag);
    if (st == atom_.end()) {
      k_.fail("miu: rob tag %u's atomic write has no read before it", tag);
      return;
    }
    const Atom &a = st->second;
    j.store = true;
    j.atom = 3;
    j.hit = false;
    j.global = a.global;
    j.spm = a.spm;
    j.bytes = a.bytes;
    j.addr = a.addr;
    j.paddr = a.paddr;
    j.active = a.pass;
    std::map<uint64_t, size_t> at;
    const Record *r = rec(j.tid, "miu");
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!(j.active >> l & 1u)) continue;
      const uint64_t line = keyOf(j, l);
      if (!at.count(line)) {
        at[line] = j.lines.size();
        j.lines.push_back({line, {}, {}, uint16_t(j.lines.size())});
      }
      LineReq &lr = j.lines[at[line]];
      const uint32_t v = getLane(am, c.rcu_miu, "store_data", l);
      for (unsigned b = 0; b != j.bytes; ++b) {
        lr.data[offOf(j, l) + b] = uint8_t(v >> (8 * b));
        lr.mask[offOf(j, l) + b] = true;
      }
      // The new value against ccv-sim's write of this lane.
      if (r)
        for (const MemAcc &w : r->mem)
          if (w.write && w.lane == l && w.val != v && !(killed_ >> (j.warp & 31) & 1u))
            k_.fail("miu: seq %llu lane %u atomic write %08x, oracle %08x",
                    (unsigned long long)r->seq, l, v, w.val);
    }
    if (j.spm) formPasses(j, am);
    k_.hit("atomic_write");
    launch(j);
  }

  /// An atomic write's ack: its completion, more while lanes are left, and
  /// its lines let go. atom-no-more: more never set, so one pass ends it.
  void atomDone(const Job &j) {
    const Ch &c = ch();
    Bits m = cmpl(j);
    const auto st = atom_.find(j.tag);
    bool more = false;
    if (st != atom_.end()) {
      st->second.left &= ~st->second.pass;
      st->second.held.clear();
      // A killed warp's atomic ends with this write (OA 436): no more passes.
      more = st->second.left != 0 && !(killed_ >> (st->second.warp & 31) & 1u);
      if (!more) atom_.erase(st);
    }
    put(m, c.miu_ooe, "more", more && k_.brk != "atom-no-more" ? 1 : 0);
    to_ooe_.push_back({j.memop_slot, m, j.tid});
  }

  void launch(Job j) {
    j.serial = ++serial_;
    j.h = now_;
    j.first = !j.fp.empty();
    jobs_.push_back(std::move(j));
  }

  /// A contracted load's first pass (MA-4): its F pipes split the warp into
  /// F groups of 32/F lanes, group g's lookup the line of its lowest active
  /// lane, on the footprint's g-th slot; a leader equal to an earlier
  /// group's is dropped, its slot idle. Eligibility already holds every
  /// active lane to its leader's line, so the first pass covers the load.
  void planFirstPass(Job &j, unsigned pipes) {
    const unsigned f = pipes ? unsigned(__builtin_popcount(pipes)) : 1u;
    const unsigned per = kLanes / f;
    unsigned slot_bits = pipes ? pipes : 1u;
    for (unsigned g = 0; g != f; ++g) {
      const unsigned slot = unsigned(__builtin_ctz(slot_bits));
      slot_bits &= slot_bits - 1;
      const uint32_t grp = uint32_t((uint64_t(1) << per) - 1) << (g * per);
      if (!(j.active & grp)) continue;
      const uint64_t line = keyOf(j, unsigned(__builtin_ctz(j.active & grp)));
      unsigned idx = 0;
      while (idx != j.lines.size() && j.lines[idx].line != line) ++idx;
      if (idx == j.lines.size()) idx = 0;   // one-line: every lane in line 0
      bool dup = false;
      for (const auto &e : j.fp) dup = dup || e.second == idx;
      if (!dup) j.fp.push_back({slot, idx});
      else if (!dup_ideal_) drops_.push_back({now_ + 1, slot, line, j.tid, "drop_dup"});   // MA-27: A2 drops it
    }
  }

  /// A contracted load that loses its first pass at A2 (a bank conflict in
  /// slot order, no credit or req_id on its slot): a miss from here, said
  /// early with the no-hit.
  void loseFirstPass(Job &j, const char *why) {
    k_.hit(why);
    if (j.inelig) return;
    j.inelig = true;
    j.hit = false;
    noHit(j.issue_at, j.memop_slot, j.tag, j.rs_idx, j.tid);
  }

  /// The banks this cycle's first passes look up (drops look up none).
  uint32_t firstPassBanks() const {
    uint32_t m = 0;
    for (const Job &j : jobs_)
      if (j.first && j.h + 1 == now_)
        for (const auto &e : j.fp) m |= 1u << bankOf(j.lines[e.second].line);
    return m;
  }
  uint32_t wf_banks_ = 0;   ///< banks this cycle's window fills took, cleared in advance()
  /// The slots this cycle's first passes own: none of them is idle.
  uint32_t firstPassSlots() const {
    uint32_t m = 0;
    for (const Job &j : jobs_)
      if (j.first && j.h + 1 == now_)
        for (const auto &e : j.fp) m |= 1u << e.first;
    for (const Drop &d : drops_)
      if (d.at == now_) m |= 1u << d.slot;
    return m;
  }

  /// Whether a store of load `j`'s warp that has not drained, older than
  /// it, touches one of its lines (MIU tab, ordering: the compare of a
  /// load's lines against the MQ's undrained stores of its warp). An
  /// uncommitted store counts if it is older; a committed one always is.
  /// Another warp's never does (MA-11).
  bool olderStore(const Job &j) const {
    const uint32_t ls = uidSeq(j.tid);
    auto overlaps = [&](const Job &st) {
      // The wide bit: a store over more than 4 lines holds every younger
      // load of its warp until it drains (MIU tab, ordering).
      if (st.lines.size() > kWideLines) { k_.hit("st_wide_hold"); return true; }
      for (const LineReq &a : st.lines)
        for (const LineReq &b : j.lines)
          if (a.line == b.line) return true;
      return false;
    };
    for (const auto &st : stores_) {
      const uint32_t ss = uidSeq(st.second.tid);
      if (seqWarp(ss) != seqWarp(ls) || seqIndex(ss) >= seqIndex(ls)) continue;
      if (overlaps(st.second)) return true;
    }
    for (const Job &st : committed_)
      if (st.warp == j.warp && overlaps(st)) return true;
    return false;
  }

  /// Whether a job in flight of the kind asked touches one of `j`'s lines:
  /// any job, a write of `j`'s warp (what a load waits for: MA-11, other
  /// warps never wait), or any warp's write (what a drain waits for).
  enum Flight { kAny, kOwnWrite, kAnyWrite };
  static constexpr size_t kWideLines = 4;
  bool inFlight(const Job &j, Flight k) const {
    for (const Job &f : jobs_)
      if (k == kOwnWrite && f.store && f.warp == j.warp && f.lines.size() > kWideLines) return true;
    for (const Job &f : jobs_)
      if (k == kAny || (f.store && (k == kAnyWrite || f.warp == j.warp)))
        for (const LineReq &a : f.lines)
          for (const LineReq &b : j.lines)
            if (a.line == b.line) return true;
    return false;
  }

  /// The addresses and store data MIU computed from what it was SENT, against
  /// what ccv-sim says the instruction accessed.
  void check(const Job &j, const Bits &am) {
    const Record *r = rec(j.tid, "miu");
    if (!r) return;
    if (j.pxfer) {
      // One word per uop (TI-36): its address, and a store's data, which is
      // the predicate's 32 bits. The word it writes, merged, is checked at
      // the drain; the one a load reads, where it lands.
      const MemAcc *a = xferAcc(r, j.tid);
      if (!a || !j.active) {
        if (!a) k_.fail("miu: seq %llu uop %u has no predicate word in ccv-sim's record",
                        (unsigned long long)r->seq, unsigned(uidSub(j.tid)));
        return;
      }
      const uint64_t at = j.addr[__builtin_ctz(j.active)];
      if (a->addr != at || a->bytes != 4)
        k_.fail("miu: seq %llu uop %u address %llx, oracle %llx", (unsigned long long)r->seq,
                unsigned(uidSub(j.tid)), (unsigned long long)at, (unsigned long long)a->addr);
      if (j.store) {
        const unsigned p = r->xferPred(uidSub(j.tid));
        for (const RegVal &u : r->uses)
          if (u.pred && u.idx == p && u.p != j.pdata)
            k_.fail("miu: seq %llu P%u's word %08x, oracle %08x", (unsigned long long)r->seq, p,
                    j.pdata, u.p);
      }
      return;
    }
    if (j.atom) {
      // An atomic (AR-21): each lane's read and write at its address.
      uint32_t lanes = 0;
      for (const MemAcc &a : r->mem) {
        lanes |= 1u << a.lane;
        if (a.addr != j.addr[a.lane] || a.shared == j.global)
          k_.fail("miu: seq %llu lane %u atomic address %llx, oracle %llx",
                  (unsigned long long)r->seq, a.lane,
                  (unsigned long long)j.addr[a.lane], (unsigned long long)a.addr);
      }
      if (lanes != j.active)
        k_.fail("miu: seq %llu active_mask %08x, but ccv-sim's atomic touched lanes %08x",
                (unsigned long long)r->seq, j.active, lanes);
      return;
    }
    uint32_t lanes = 0;
    for (const MemAcc &a : r->mem) lanes |= 1u << a.lane;
    if (lanes != j.active || r->store != j.store) {
      k_.fail("miu: seq %llu active_mask %08x, but ccv-sim's %s touched lanes %08x",
              (unsigned long long)r->seq, j.active, r->store ? "store" : "load", lanes);
      return;
    }
    for (const MemAcc &a : r->mem) {
      if (a.addr != j.addr[a.lane] || a.shared == j.global)
        k_.fail("miu: seq %llu lane %u address %llx, oracle %llx",
                (unsigned long long)r->seq, a.lane,
                (unsigned long long)j.addr[a.lane], (unsigned long long)a.addr);
      else if (a.bytes != j.bytes)
        k_.fail("miu: seq %llu lane %u moves %u bytes, oracle %u", (unsigned long long)r->seq,
                a.lane, j.bytes, a.bytes);
      // A narrow store sends its register's row; only its element is data.
      const uint32_t bm = j.bytes == 4 ? ~0u : (1u << (8 * j.bytes)) - 1;
      if (j.store && r->kind != "fault" &&
          (getLane(am, ch().rcu_miu, "store_data", a.lane) & bm) != (a.val & bm))
        k_.fail("miu: seq %llu lane %u store data %08x, oracle %08x",
                (unsigned long long)r->seq, a.lane,
                getLane(am, ch().rcu_miu, "store_data", a.lane) & bm, a.val & bm);
    }
  }

  Bits cmpl(const Job &j) {
    const Ch &c = ch();
    Bits m = msgOf(c.miu_ooe);
    put(m, c.miu_ooe, "rob_tag", j.tag);
    put(m, c.miu_ooe, "done_row", cmpl_row_[j.tag]);   // the memop's row (OI-85)
    // The RS entry, echoed from the memop as phys_dst is to RCU, so MIU holds
    // no table of it and OOE wakes the entry with no lookup (OA-23).
    put(m, c.miu_ooe, "rs_idx", k_.brk == "rs-echo" ? j.rs_idx ^ 1u : j.rs_idx);
    put(m, c.miu_ooe, "lane_mask", j.active);
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l) & 1u) { put(m, c.miu_ooe, "address", j.addr[l]); break; }
    put(m, c.miu_ooe, "mlc_miss", j.mlc_miss ? 1 : 0);
    return m;
  }

  /// A whole crossing of a channel: CCV_LAT_HOP plus its repeater stages and
  /// a flopped receiving end's cycle, bnd_rx (AR's revs 300 and 301).
  static unsigned crossing(unsigned chan) {
    for (const ChanInst &ci : kChanInsts)
      if (ci.chan == chan) return kLatHop + ci.stages + ci.bnd_rx;
    return kLatHop;
  }

  void advance() {
    const Ch &c = ch();
    const unsigned rate = kChans[c.miu_dcu].rate;
    // This cycle's first passes (MA-4), each on its own slot, in slot order:
    // a lookup whose bank an earlier slot's took loses its first pass and
    // its contract, never the earlier one's (DCU's 8 banks by [9:7]). Then
    // every slot no first pass used carries later passes, drains and
    // atomics' passes, the oldest job's first, one lookup a bank a cycle.
    bool want = false;
    for (const Job &j : jobs_) want = want || j.next != j.lines.size();
    if (want && !ids_.anyFree()) k_.hit("dcu_id_wait");
    uint32_t used = 0;
    std::set<unsigned> banks;
    for (unsigned b = 0; b != ccv::kDcuBanks; ++b)
      if (wf_banks_ >> b & 1u) banks.insert(b);
    wf_banks_ = 0;
    auto request = [&](Job &job_, unsigned idx, unsigned s) {
      LineReq &lr = job_.lines[idx];
      lr.sent = true;
      ++job_.next;
      used |= 1u << s;
      banks.insert(bankOf(lr.line));
      Bits r = msgOf(c.miu_dcu);
      const unsigned id = ids_.take(s);
      put(r, c.miu_dcu, "req_id", id);
      put(r, c.miu_dcu, "phys_addr", lr.line);
      putIndexLead(r, lr.line);
      put(r, c.miu_dcu, "size", kSizeLine);
      const bool wr = job_.store && job_.rmw != 1;   // a drain's read first
      bankTake(bankOf(lr.line), wr);
      if (bank_held_.erase({job_.serial, idx})) k_.hit("credit_hold_then_sent");
      put(r, c.miu_dcu, "coh_op", wr ? kCohWrite : job_.atom == 1 ? kCohAcquireData : kCohRead);
      if (wr) {
        putLine(r, field(c.miu_dcu, "write_data").lsb, lr.data);
        const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
        for (unsigned k = 0; k != kLine; ++k) r.setBit(mlsb + k, lr.mask[k]);
      }
      const uint64_t tid =
          makeUid(IdClass::kTxn, uidSeq(job_.tid), lr.sub, /*owned=*/true);
      send(c.miu_dcu, s, r, tid);
      if (ltrace_)
        std::fprintf(stderr, "LTRACE %llu req tag %u slot %u line %llx\n", (unsigned long long)now_,
                     job_.tag, s, (unsigned long long)lr.line);
      outstanding_[id] = {job_.serial, lr.line};
      k_.hit("dcu_lookups");
      if (job_.frame) k_.hit("frame_lookups");
    };
    std::vector<std::tuple<unsigned, Job *, unsigned>> firsts;
    for (Job &j : jobs_)
      if (j.first && j.h + 1 <= now_) {
        for (const auto &e : j.fp) firsts.push_back({e.first, &j, e.second});
        j.first = false;
      }
    // A2's drops of lookups A1 launched last cycle (MA-27) take their slots
    // in the same order: a null job.
    for (size_t d = 0; d != drops_.size(); ++d)
      if (drops_[d].at == now_) firsts.push_back({drops_[d].slot, nullptr, unsigned(d)});
    std::stable_sort(firsts.begin(), firsts.end(),
                     [](const auto &x, const auto &y) { return std::get<0>(x) < std::get<0>(y); });
    // MA-25: a line an older request is held on for a credit, and a bank an
    // older store is held on, block younger requests; first passes are the
    // youngest of all. A first pass without its bank's entry credit loses
    // its contract like one without a slot, and is held for the credit.
    std::set<uint64_t> older_held_lines;
    std::set<unsigned> older_held_banks;   // a request held on the bank: the credit is its first
    for (const Job &j : jobs_)
      for (unsigned idx = 0; idx != j.lines.size(); ++idx)
        if (!j.lines[idx].sent && bank_held_.count({j.serial, idx})) {
          older_held_lines.insert(j.lines[idx].line);
          older_held_banks.insert(bankOf(j.lines[idx].line));
        }
    // A dropped lookup (MA-27, AR 400): the valid and lead A1 launched, the
    // payload with drop set; no req_id (don't-care, 0), no data. Its valid
    // spent its bank's entry credit and miu_cred refunds it a cycle on. A1's
    // gate and holds apply as to any first pass: held, nothing launches.
    // dcu-drop-answers (the DCU stub's control) answers it, and the answer
    // is refused as a response to no outstanding request.
    auto sendDrop = [&](unsigned s, const Drop &d) {
      const unsigned fb = bankOf(d.line);
      if (older_held_lines.count(d.line) || older_held_banks.count(fb) || !a1Gate(fb) ||
          !bankCan(fb, false) || !can(c.miu_dcu, s) || (used >> s & 1u)) {
        return;   // held at A1: nothing launches
      }
      // The launch takes slot s's id (miu_lead's launch flop, the take) and
      // the drop gives it back three cycles on (MI-28); held at A1 if the
      // quarter holds none.
      unsigned rid = 0;
      if (!ids_dropfree_) {
        if (!ids_.any(s)) {
          idStall(s);
          return;
        }
        rid = ids_.take(s, /*drop=*/true);
      }
      a1_used_now_ |= 1u << fb;
      bankTake(fb, false);
      a1_refund_.push_back(fb);
      used |= 1u << s;
      Bits r = msgOf(c.miu_dcu);
      put(r, c.miu_dcu, "req_id", rid);
      put(r, c.miu_dcu, "phys_addr", d.line);
      putIndexLead(r, d.line);
      put(r, c.miu_dcu, "size", kSizeLine);
      put(r, c.miu_dcu, "coh_op", kCohRead);
      put(r, c.miu_dcu, "drop", 1);
      send(c.miu_dcu, s, r, makeUid(IdClass::kTxn, uidSeq(d.tid), uint16_t(0xff00u | s), /*owned=*/true));
      k_.hit(d.why);
      k_.hit("dcu_drops");
    };
    for (auto &[s, jp, idx] : firsts) {
      if (!jp) { sendDrop(s, drops_[idx]); continue; }
      Job &j = *jp;
      if (j.h + 1 != now_) { loseFirstPass(j, "l1_first_late"); continue; }
      const uint64_t fl = j.lines[idx].line;
      const unsigned fb = bankOf(fl);
      // A1 (H): the gate on flops alone (a1Gate), and an older request held
      // on the line or bank. A gate passed with no credit left is a spend
      // past the count in RTL: reported, and held here.
      if (a1Gate(fb) && !bankCan(fb, false) && !a1_short_++)
        std::fprintf(stderr, "miu: A1 gate passed for bank %u with %d entry credits (cycle %llu)\n",
                     fb, bent_[fb], (unsigned long long)now_);
      if (older_held_lines.count(fl) || older_held_banks.count(fb) || !a1Gate(fb) || !bankCan(fb, false)) {
        bank_held_.insert({j.serial, idx});
        k_.hit("credit_hold");
        // MI-27 (1)'s price: held only because another bank is short, the
        // leader's own gate (and everything else) sufficient.
        if (gate_all_ && !older_held_lines.count(fl) && !older_held_banks.count(fb) &&
            leaderGate(fb) && bankCan(fb, false))
          pbin("credit_hold_other_bank");
        loseFirstPass(j, "l1_first_held");
        continue;
      }
      if (!can(c.miu_dcu, s)) { loseFirstPass(j, "l1_first_held"); continue; }
      if (!ids_.any(s)) {
        idStall(s);
        loseFirstPass(j, "l1_first_held");
        continue;
      }
      // A2 (H+1): the valid launched from A1 and spent its bank's credit;
      // a bank-conflict loser is dropped (MA-27, AR 400) and miu_cred
      // refunds the credit from A2's flopped drop a cycle on (a1_refund_).
      if (banks.count(fb)) {
        loseFirstPass(j, "l1_bank_loser");
        sendDrop(s, {now_, s, fl, j.tid, "drop_bank"});
        continue;
      }
      a1_used_now_ |= 1u << fb;
      request(j, idx, s);
      k_.hit("l1_first_pass");
    }
    drops_.erase(std::remove_if(drops_.begin(), drops_.end(),
                                [&](const Drop &d) { return d.at <= now_; }),
                 drops_.end());
    // Later passes, oldest job first: what a held request blocks is built
    // as the walk goes, so it blocks only younger ones, never itself.
    std::set<uint64_t> held_lines;
    std::set<unsigned> held_store_banks;
    for (Job &j : jobs_) {
      // No pass leaves before A2's flops (h + 1), where a first pass leaves:
      // a load that lost its contract at A2 (drop_l0, drop_split, ...)
      // sends its lines from the same flops, never a cycle ahead of the
      // first pass it lost (MI-31 trace; MA rev 199 (3)).
      if (j.first || j.next == j.lines.size() || now_ < j.h + 1) continue;
      for (unsigned idx = 0; idx != j.lines.size(); ++idx) {
        if (j.lines[idx].sent || banks.count(bankOf(j.lines[idx].line))) continue;
        const uint64_t ln = j.lines[idx].line;
        const bool st = j.store && j.rmw != 1;
        if (held_lines.count(ln) || (st && held_store_banks.count(bankOf(ln))) || !bankCan(bankOf(ln), st)) {
          held_lines.insert(ln);
          if (st) held_store_banks.insert(bankOf(ln));
          bank_held_.insert({j.serial, idx});
          k_.hit("credit_hold");
          continue;   // its other lines, to other lines and banks, may go
        }
        unsigned s = 0, open = rate;
        while (s != rate && ((used >> s & 1u) || !can(c.miu_dcu, s) || !ids_.any(s))) {
          if (open == rate && !(used >> s & 1u) && can(c.miu_dcu, s)) open = s;
          ++s;
        }
        if (s == rate) {
          if (open != rate) idStall(open);
          break;
        }
        request(j, idx, s);
      }
    }
    // Up to one pass per SPM slot per cycle, likewise.
    const unsigned srate = kChans[c.miu_spm].rate;
    unsigned ss = 0;
    for (Job &jb : jobs_)
      for (; ss != srate && jb.pnext != jb.passes.size(); ++ss) {
        if (!can(c.miu_spm, ss) || !spm_ids_.any()) continue;
        const unsigned p = jb.pnext++;
        const Job::Pass &ps = jb.passes[p];
        Bits r = msgOf(c.miu_spm);
        const unsigned id = spm_ids_.take();
        put(r, c.miu_spm, "req_id", id);
        const uint32_t alsb = field(c.miu_spm, "bank_addr").lsb;
        for (unsigned b = 0; b != ccv::kSpmBanks; ++b)
          r.set(alsb + ccv::kWSpmWord * b, ccv::kWSpmWord, ps.word[b]);
        putLine(r, field(c.miu_spm, "write_data").lsb, ps.data);
        const uint32_t mlsb = field(c.miu_spm, "byte_mask").lsb;
        for (unsigned k = 0; k != kLine; ++k) r.setBit(mlsb + k, ps.mask[k]);
        put(r, c.miu_spm, "spm_op", jb.store ? kSpmWrite : kSpmRead);
        send(c.miu_spm, ss, r, makeUid(IdClass::kTxn, uidSeq(jb.tid), p, /*owned=*/true));
        spm_out_[id] = {jb.serial, p};
        k_.hit("spm_pass");
      }
    for (auto it = jobs_.begin(); it != jobs_.end();) {
      if (it->back != it->lines.size() || it->pback != it->passes.size()) { ++it; continue; }
      // A hinted load the kill supplied keeps its promise's cycle (OA-23).
      if (it->moot && it->promised && now_ < it->promised) { ++it; continue; }
      if (it->rmw == 1) { merge(*it); ++it; continue; }
      if (it->walk) {
        walk_out_ = false;
        if (walker_.got()) walkDone();
        it = jobs_.erase(it);
        continue;
      }
      if (!it->store) complete(*it);
      else if (it->atom == 3) atomDone(*it);
      else storeGone(*it);
      it = jobs_.erase(it);
    }
  }

  /// A predicate store's drain, its line read: the word merged under its
  /// mask, new = (old & ~m) | (d & m), and held to ccv-sim's; then written.
  /// m is active_mask, the issue mask (st.pred has no guard). The line stays
  /// in flight from the read to the write, so nothing reaches it between.
  /// stpred-whole-word: every lane's bit stored, the group's or not.
  void merge(Job &j) {
    LineReq &lr = j.lines[0];
    const uint64_t a = j.addr[__builtin_ctz(j.active)];
    const unsigned off = unsigned(a % kLine);
    const Line &old_line = j.got.at(lr.line);
    uint32_t old = 0;
    for (unsigned b = 0; b != 4; ++b) old |= uint32_t(old_line[off + b]) << (8 * b);
    const uint32_t m = k_.brk == "stpred-whole-word" ? ~0u : j.active;
    const uint32_t v = (old & ~m) | (j.pdata & m);
    if (const MemAcc *o = xferAcc(rec(j.tid, "miu"), j.tid))
      if (o->val != v)
        k_.fail("miu: seq %llu P%u merged %08x into %llx, oracle %08x",
                (unsigned long long)uidSeq(j.tid),
                rec(j.tid, "miu")->xferPred(uidSub(j.tid)), v, (unsigned long long)a, o->val);
    for (unsigned b = 0; b != 4; ++b) {
      lr.data[off + b] = uint8_t(v >> (8 * b));
      lr.mask[off + b] = true;
    }
    k_.hit("pred_merge");
    j.rmw = 2;
    j.next = j.back = 0;
    for (LineReq &l : j.lines) l.sent = false;
    j.got.clear();
  }

  /// A load with every line back: its data to RCU and its completion to OOE,
  /// at the L1 contract if every line hit in time, else as a miss.
  void complete(const Job &job_) {
    const Ch &c = ch();
    {
      Bits d = msgOf(c.miu_rcu);
      put(d, c.miu_rcu, "rob_tag", job_.tag);
      put(d, c.miu_rcu, "active_mask", job_.active);
      put(d, c.miu_rcu, "phys_dst",
          job_.phys_dst + (k_.brk == "corrupt-echo" && uidSeq(job_.tid) == 12 ? 1u : 0u));
      put(d, c.miu_rcu, "dst_pos", job_.dst_pos);
      put(d, c.miu_rcu, "dst_width", job_.chw);
      put(d, c.miu_rcu, "phys_pred", job_.phys_pred);
      put(d, c.miu_rcu, "pred_we", 0);          // a load writes no predicate
      // A killed warp's line the kill supplied holds no data: nothing to
      // hold to ccv-sim's.
      const Record *r = job_.moot ? nullptr : rec(job_.tid, "miu");
      if (job_.pxfer && job_.active) {
        // A predicate load (TI-36): its word is the predicate, lane i's bit
        // for lane i, written by RCU under active_mask (O-62), the copy op
        // writing the rest. No GPR: phys_dst is the zero register.
        // ldpred-whole-word: every lane's bit written, the group's or not.
        const uint64_t a = job_.addr[__builtin_ctz(job_.active)];
        const Line &ln = job_.got.at(a / kLine * kLine);
        uint32_t v = 0;
        for (unsigned b = 0; b != 4; ++b) v |= uint32_t(ln[a % kLine + b]) << (8 * b);
        if (const MemAcc *o = xferAcc(r, job_.tid))
          if (o->val != v)
            k_.fail("miu: seq %llu P%u loaded %08x from %llx, oracle %08x",
                    (unsigned long long)uidSeq(job_.tid), r->xferPred(uidSub(job_.tid)), v,
                    (unsigned long long)a, o->val);
        put(d, c.miu_rcu, "pred_we", 1);
        put(d, c.miu_rcu, "pred_result", v);
        put(d, c.miu_rcu, "phys_dst", ccv::prov::kPhysZero);   // no GPR: RCU writes none
        if (k_.brk == "ldpred-whole-word") put(d, c.miu_rcu, "active_mask", ~0u);
      }
      for (unsigned l = 0; l != kLanes && !job_.pxfer; ++l) {
        if (!((job_.active >> l) & 1u)) continue;
        const Line &ln = job_.got.at(k_.brk == "one-line" ? job_.lines[0].line : keyOf(job_, l));
        const unsigned off = offOf(job_, l);
        uint32_t v = 0;
        for (unsigned b = 0; b != job_.bytes; ++b) v |= uint32_t(ln[off + b]) << (8 * b);
        // What came back from memory, against what ccv-sim loaded.
        if (r)
          for (const MemAcc &a : r->mem)
            if (a.lane == l && !a.write && a.val != v)
              k_.fail("miu: seq %llu lane %u loaded %08x, oracle %08x",
                      (unsigned long long)r->seq, l, v, a.val);
        // A sized load is zero- or sign-filled to rdata's width (O-80; MIU
        // spec rev 38), which RCU writes at dst_width as ever.
        if (job_.bytes != 4 && job_.xsigned && (v >> (8 * job_.bytes - 1) & 1u))
          v |= ~0u << (8 * job_.bytes);
        v &= elemMask(job_.chw);
        if (k_.brk == "corrupt-load" && r && r->seq == 13 && l == 5) v ^= 1;
        putLane(d, c.miu_rcu, "load_data", l, v);
      }
      if (job_.promised) {
        // Hinted: the completion and its data leave now, on the credits held
        // back for them, or the promise is broken and the bank says so.
        --resv_[{c.miu_ooe, job_.memop_slot}];
        --resv_[{c.miu_rcu, job_.addr_slot}];
        if (now_ != job_.promised)
          k_.fail("miu: rob tag %u's hinted completion due at cycle %llu is ready at %llu",
                  job_.tag, (unsigned long long)job_.promised, (unsigned long long)now_);
        if (k_.brk == "late-cmpl") {
          // The hinted completion a cycle after its promise, with its data.
          timed_.push_back({now_ + 1, {job_.addr_slot, d, job_.tid},
                            {job_.memop_slot, cmpl(job_), job_.tid}});
        } else if (now_ == job_.promised && can(c.miu_ooe, job_.memop_slot) &&
                   can(c.miu_rcu, job_.addr_slot)) {
          sendCmpl(job_.memop_slot, cmpl(job_), job_.tid);
          send(c.miu_rcu, job_.addr_slot, d, job_.tid);
        } else {
          to_rcu_.push_back({job_.addr_slot, d, job_.tid});
          to_ooe_.push_back({job_.memop_slot, cmpl(job_), job_.tid});
        }
      } else if (job_.hit && job_.global && now_ + ccv::prov::kLatL1Ecc <= job_.due) {
        // Queued for the data's cycle, CCV_LAT_L1_ECC ahead of the
        // completion's contract (AR 368).
        timed_.push_back({job_.due - ccv::prov::kLatL1Ecc, {job_.addr_slot, d, job_.tid},
                          {job_.memop_slot, cmpl(job_), job_.tid}, false, job_.ecc});
      } else if (job_.inelig && now_ <= job_.due) {
        // An ineligible load completes past the contract's cycle, never on
        // or before it (MA-4: no completion at H+7; A-46, V-44).
        held_.push_back({job_.due + 1, {job_.addr_slot, d, job_.tid},
                         {job_.memop_slot, cmpl(job_), job_.tid}});
      } else {
        // A hit DCU answered past the contract's data cycle: a way
        // mispredict re-read on the bank-conflict loser's path, due + 2 at
        // the earliest (DI-2; AR 390, OA-442), or any other late answer. MIU
        // cannot tell which from its ports; either way it is a miss to OOE.
        if (job_.hit) {
          k_.hit("l1_late");
          k_.hit("l1_dcu_late");
        }
        to_rcu_.push_back({job_.addr_slot, d, job_.tid});
        // Past the data's cycle but not the completion's (CCV_LAT_L1_ECC
        // apart): the completion still goes past the contract, or OOE takes
        // it for a hit whose dependants read the register before the data.
        if (job_.global && now_ <= job_.due)
          late_faults_.push_back({job_.due + 1, {job_.memop_slot, cmpl(job_), job_.tid}});
        else
          to_ooe_.push_back({job_.memop_slot, cmpl(job_), job_.tid});
      }
    }
  }

  // DCU's per-bank credits (MA-25; MIU tab, bank credits), reset full: a
  // lookup goes only with its bank's entry credit, a store's write only with
  // that and a store-data credit, both spent at send and returned on
  // ccv_dcu_miu_cred. A request without its credits is held, oldest first:
  // a held request blocks every younger one to its line, a held store every
  // younger store to its bank. The params are the defaults, and the
  // environment's CCV_DCU_BANK_QDEPTH and CCV_DCU_BANK_STDATA override them,
  // as in both stubs and the DCU model. --break bank-credit-ignore sends
  // without them (the counts go negative), which DCU must refuse by name.
  static unsigned bankEnv(const char *name, unsigned dflt) {
    const char *v = std::getenv(name);
    const unsigned n = v && *v ? unsigned(std::strtoul(v, nullptr, 10)) : dflt;
    return n >= 1 ? n : dflt;
  }
  static unsigned bankOf(uint64_t line) { return unsigned((line / kLine) % ccv::kDcuBanks); }
  const unsigned bqdepth_ = bankEnv("CCV_DCU_BANK_QDEPTH", ccv::prov::kDcuBankQdepth),
                 bstdata_ = bankEnv("CCV_DCU_BANK_STDATA", ccv::prov::kDcuBankStdata);
  uint64_t cred_pend_ent_ = 0, cred_pend_std_ = 0;   // returns captured, counted next cycle
  std::vector<int> bent_ = std::vector<int>(ccv::kDcuBanks, int(bqdepth_)),
                   bstd_ = std::vector<int>(ccv::kDcuBanks, int(bstdata_));
  /// Requests held for a credit, by (job serial, line index); a window fill
  /// held for one, by its memop's rob tag. Each counts credit_hold_then_sent
  /// when it goes.
  std::set<std::pair<uint64_t, unsigned>> bank_held_;
  std::set<unsigned> fill_held_;
  bool bankCan(unsigned b, bool store) const {
    return k_.brk == "bank-credit-ignore" || (bent_[b] > 0 && (!store || bstd_[b] > 0));
  }
  void bankTake(unsigned b, bool store) {
    --bent_[b];
    if (store) --bstd_[b];
  }
  // The A1 gate on a first pass's bank (MA-27 (2), MI-17; MIU tab rev 149):
  // A1 decides the valid that launches at H+1 from flops alone. miu_cred
  // flops ge1[b] (count >= CCV_DCACHE_LOOKUPS) and ge2[b] (>= 2x) from its
  // count net of every spend launched and every return that cycle; miu_lead
  // flops used[b], a first pass it launched to bank b. A first pass that
  // launches now was decided at A1 a cycle ago, reading the flops the cycle
  // before that: ge from the counts after cycle now-2, used from cycle now-1
  // (the launch the flops did not yet see). The gate is used ? ge2 : ge1;
  // below it the load is held at A1 and loses its contract (l1_first_held,
  // credit_hold), and goes in a later pass. A gate passed with no credit left
  // would be a spend past the count in RTL; the model reports it on stderr.
  // No kernel yet puts two first passes on one bank in a cycle (MI-9 (3)),
  // so the gate's control waits for that kernel.
  std::vector<uint8_t> ge1_a_ = std::vector<uint8_t>(ccv::kDcuBanks, 1),
                       ge2_a_ = std::vector<uint8_t>(ccv::kDcuBanks, 1),
                       ge1_b_ = std::vector<uint8_t>(ccv::kDcuBanks, 1),
                       ge2_b_ = std::vector<uint8_t>(ccv::kDcuBanks, 1);
  uint32_t a1_used_now_ = 0, a1_used_prev_ = 0;   // first passes launched, by bank
  unsigned a1_short_ = 0;                          // gates passed with no credit
  /// A lookup A1 launched and A2 drops (MA-27, AR 400): on the wire at H+1
  /// with drop set, on its slot, spending its bank's entry credit, which
  /// miu_cred refunds from A2's flopped drop a cycle on (a1_refund_).
  struct Drop { uint64_t at; unsigned slot; uint64_t line; uint64_t tid; const char *why; };
  std::vector<Drop> drops_;
  /// CCV_MIU_DUP_IDEAL=1: a duplicate leader's valid never launches, an
  /// oracle with no RTL meaning, to price an A1 dedupe (MI-19 (3a), MA rev
  /// 147). 0, the default: A1 launches every group leader and A2 drops the
  /// duplicates, as slice 1's RTL does.
  const bool dup_ideal_ = [] {
    const char *v = std::getenv("CCV_MIU_DUP_IDEAL");
    return v && std::strtoul(v, nullptr, 0) != 0;
  }();
  std::vector<unsigned> a1_refund_;                // dropped first passes' banks, refunded next cycle
  bool a1Gate(unsigned b) const {
    if (gate_all_) {   // MI-27 (1): every bank's gate, whatever the leader's
      for (unsigned x = 0; x != ccv::kDcuBanks; ++x)
        if (!((a1_used_prev_ >> x & 1u) ? ge2_b_[x] : ge1_b_[x])) return false;
      return true;
    }
    return leaderGate(b);
  }
  bool leaderGate(unsigned b) const {
    const bool used = a1_used_prev_ >> b & 1u;
    return used ? ge2_b_[b] : ge1_b_[b];
  }
  /// MI-27 pricing aids (model-only knobs, default off). CCV_MIU_GATE_ALL=1:
  /// A1's credit gate holds a first pass when any bank is short, not only
  /// its leader's. CCV_MIU_LEAD_POS=1: a group's leader is its first lane by
  /// position; a group with active lanes whose first lane is inactive loses
  /// the contract at A2 (drop_lead_pos).
  static bool envOn(const char *n) {
    const char *v = std::getenv(n);
    return v && std::strtoul(v, nullptr, 0) != 0;
  }
  const bool gate_all_ = envOn("CCV_MIU_GATE_ALL");
  const bool lead_pos_ = envOn("CCV_MIU_LEAD_POS");
  /// Pricing bins outside the kernel's COVER list (model-only): counted
  /// here as well, and printed as one MIUBINS line at the end of the run
  /// under CCV_MIU_PBINS=1.
  std::map<std::string, uint64_t> pbin_;
  void pbin(const char *n) {
    k_.hit(n);
    ++pbin_[n];
  }
  const bool pbins_ = envOn("CCV_MIU_PBINS");
  /// CCV_MIU_LTRACE=1 (model-only): each load's A2 eligibility and each completion, to stderr.
  const bool ltrace_ = envOn("CCV_MIU_LTRACE");
  /// MI-30 pricing aid (model-only, default off): CCV_MIU_L0=n gives each
  /// lookup slot an n-entry round-robin L0 TLB in front of the leaders (eligibility).
  struct L0Fill { uint64_t at; unsigned slot; uint64_t page; };
  std::deque<L0Fill> l0_q_, l0_w_;   // pending a grant; granted, awaiting the L0 write
  const bool l0_bcast_ = envOn("CCV_MIU_L0_BCAST");
  const unsigned tlb_ports_ = [] {
    const char *v = std::getenv("CCV_MIU_TLB_PORTS");
    return v ? unsigned(std::strtoul(v, nullptr, 0)) : 4u;
  }();
  /// A3: up to tlb_ports_ refills a cycle, oldest first.
  void l0Refill() {
    while (!l0_w_.empty() && l0_w_.front().at <= now_) {
      if (l0_bcast_)   // CCV_MIU_L0_BCAST=1: a refill writes every slot's L0
        for (miu::Tlb &t : l0_) t.fill(l0_w_.front().page);
      else
        l0_[l0_w_.front().slot].fill(l0_w_.front().page);
      l0_w_.pop_front();
    }
    unsigned n = 0;
    for (auto it = l0_q_.begin(); it != l0_q_.end() && it->at <= now_;) {
      if (n == tlb_ports_) { pbin("l0_refill_wait"); ++it; continue; }
      l0_w_.push_back({now_ + 3, it->slot, it->page});
      ++n;
      it = l0_q_.erase(it);
    }
  }
  /// CCV_MIU_L0_LRU=1 (pricing aid, MA rev 203 (3)): the L0 replaces its
  /// least recently used entry, a hit refreshing it; else round robin.
  std::vector<miu::Tlb> l0_ = [] {
    const char *v = std::getenv("CCV_MIU_L0");
    const unsigned n = v ? unsigned(std::strtoul(v, nullptr, 0)) : 0u;
    return n ? std::vector<miu::Tlb>(ccv::prov::kDcacheLookups, miu::Tlb(n, !envOn("CCV_MIU_L0_LRU")))
             : std::vector<miu::Tlb>();
  }();
  void a1GateFlop() {
    ge1_b_ = ge1_a_;
    ge2_b_ = ge2_a_;
    for (unsigned b = 0; b != ccv::kDcuBanks; ++b) {
      ge1_a_[b] = bent_[b] >= int(ccv::prov::kDcacheLookups);
      ge2_a_[b] = bent_[b] >= 2 * int(ccv::prov::kDcacheLookups);
    }
    a1_used_prev_ = a1_used_now_;
    a1_used_now_ = 0;
  }
  bool busy() const override {
    return cred_pend_ent_ || cred_pend_std_ || !jobs_.empty() || !drops_.empty() || !late_faults_.empty() || !held_.empty() || !ecc_beats_.empty() || !order_.empty() || !stores_.empty() || !timed_.empty() ||
           !hints_.empty() || !orphan_.empty() || !to_rau_.empty() || !ue_first_.empty() ||
           !spm_out_.empty() || !spm_orphan_.empty() ||
           !committed_.empty() || !to_rcu_.empty() || !to_ooe_.empty() ||
           !to_dcu_.empty() || !to_fet_.empty();
  }
};

} // namespace

std::unique_ptr<Block> makeMiuModel(int inst, Kernel &k) { return std::make_unique<MiuModel>(inst, k); }

} // namespace skel
} // namespace ccv
