//===-- kernel.cpp - S1 functional stubs ---------------------------------===//
//
// One stub per block type. Each reads only its own receivers and writes only
// its own senders, pops every message the cycle it lands (so the bank's
// bounded-response check measures the stub, not a backlog), and checks what
// arrived against the oracle record wherever the record says what it should
// be. Nothing here uses a message's trace identity to decide what to DO --
// only to find the record a check compares against. The two exceptions are
// named where they happen: fetch order and decode (strategy §1's "what"), and
// the per-lane address offset (open question agu_immediate).
//===----------------------------------------------------------------------===//
#include "kernel.h"

#include "ccv/event.h"
#include "exerciser.h"

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <set>
#include <tuple>

namespace ccv {
namespace skel {

void Kernel::fail(const char *fmt, ...) {
  if (failures < 12) {
    va_list ap;
    va_start(ap, fmt);
    std::fprintf(stderr, "CHECK ");
    std::vfprintf(stderr, fmt, ap);
    std::fputc('\n', stderr);
    va_end(ap);
  }
  ++failures;
}

namespace {

// ---- channels and fields, by name --------------------------------------------

unsigned chanId(const char *n) {
  for (const ChanDesc &cd : kChans)
    if (!std::strcmp(cd.name, n)) return cd.id;
  std::fprintf(stderr, "kernel stubs: no channel %s in the wiring\n", n);
  std::abort();
}

struct Ch {
  unsigned fet_dec = chanId("ccv_fet_dec_instr"), dec_ooe = chanId("ccv_dec_ooe_uop"),
           ooe_rcu = chanId("ccv_ooe_rcu_issue"), rcu_lane = chanId("ccv_rcu_lane_ops"),
           lane_rcu = chanId("ccv_lane_rcu_res"), rcu_ooe = chanId("ccv_rcu_ooe_done"),
           rcu_miu = chanId("ccv_rcu_miu_addr"), miu_rcu = chanId("ccv_miu_rcu_data"),
           ooe_miu = chanId("ccv_ooe_miu_memop"), miu_ooe = chanId("ccv_miu_ooe_cmpl"),
           ooe_ret = chanId("ccv_ooe_miu_retire"), miu_dcu = chanId("ccv_miu_dcu_req"),
           dcu_miu = chanId("ccv_dcu_miu_rsp"), dcu_mlc = chanId("ccv_dcu_mlc_req"),
           mlc_dcu = chanId("ccv_mlc_dcu_rsp"), fet_mlc = chanId("ccv_fet_mlc_ifill"),
           mlc_fet = chanId("ccv_mlc_fet_ifill_rsp"), miu_fet = chanId("ccv_miu_fet_itlb"),
           fet_miu = chanId("ccv_fet_miu_itlb_req"), mlc_exb = chanId("ccv_mlc_exb_req"),
           exb_mlc = chanId("ccv_exb_mlc_rsp"), exb_ext = chanId("ccv_exb_ext_out"),
           ext_exb = chanId("ccv_ext_exb_in"), rau_fet = chanId("ccv_rau_fet_launch"),
           rau_ooe = chanId("ccv_rau_ooe_alloc"), rau_miu = chanId("ccv_rau_miu_cta");
};
const Ch &ch() { static const Ch c; return c; }

const FieldDesc &field(unsigned chan, const char *n) {
  const ChanDesc &cd = kChans[chan];
  for (unsigned f = 0; f != cd.nfields; ++f)
    if (!std::strcmp(cd.fields[f].name, n)) return cd.fields[f];
  std::fprintf(stderr, "kernel stubs: %s has no field %s\n", cd.name, n);
  std::abort();
}
uint64_t get(const Bits &b, unsigned chan, const char *f) {
  const FieldDesc &fd = field(chan, f);
  return b.get(fd.lsb, fd.width < 64 ? fd.width : 64);
}
void put(Bits &b, unsigned chan, const char *f, uint64_t v) {
  const FieldDesc &fd = field(chan, f);
  b.set(fd.lsb, fd.width < 64 ? fd.width : 64, v);
}
/// Per-lane 32-bit element L of a wide field: bits [32L+31 : 32L] of it.
uint32_t getLane(const Bits &b, unsigned chan, const char *f, unsigned l) {
  return uint32_t(b.get(field(chan, f).lsb + 32 * l, 32));
}
void putLane(Bits &b, unsigned chan, const char *f, unsigned l, uint32_t v) {
  b.set(field(chan, f).lsb + 32 * l, 32, v);
}
Bits msgOf(unsigned chan) { return Bits(kChans[chan].bits); }

constexpr unsigned kLine = 128;            // bytes: CCV_W_DATA / 8
using Line = std::array<uint8_t, kLine>;

void putLine(Bits &b, uint32_t lsb, const Line &l) {
  for (unsigned k = 0; k != kLine; ++k) b.set(lsb + 8 * k, 8, l[k]);
}
Line getLine(const Bits &b, uint32_t lsb) {
  Line l;
  for (unsigned k = 0; k != kLine; ++k) l[k] = uint8_t(b.get(lsb + 8 * k, 8));
  return l;
}

// ---- S1 wire conventions (docs/skeleton.md lists them) ------------------------
//
// Placeholders for encodings the payload spec leaves to the owning block.
enum : unsigned { kCohRead = 0, kCohWrite = 1 };        // coh_op
enum : unsigned { kMemLoad = 0, kMemStore = 1 };        // ooe_miu_memop.mem_op
enum : unsigned { kSizeLine = 7 };                      // size: 2^7 bytes
// The testbench link. tl_out / tl_in are single opaque fields whose TileLink
// encoding is the EXB session's; this is enough to move a line.
enum : unsigned { kTlGet = 1, kTlPutFull = 2, kTlAckData = 1, kTlAck = 2 };
// The source id is MLC's req_id on that hop, as TL-C matches D to A by source.
constexpr uint32_t kTlOp = 0, kTlSrc = 3, kTlAddr = 9, kTlMask = 57,
                   kTlData = 185;                                  // tl_out
constexpr uint32_t kTlInOp = 0, kTlInSrc = 3, kTlInData = 9;       // tl_in
constexpr uint32_t kTlSrcW = 6;

// ---- the opcode table ---------------------------------------------------------
//
// The skeleton's decoder: an opcode per operation vadd uses, and the operand
// shape rename and register read need. Opcode values are skeleton-local
// (payload spec: opcode is 9 bits, preliminary) -- 0 is reserved.
enum UopClass : uint8_t { kAlu, kLoad, kStore, kBranch, kExit, kPredLogic };
struct OpInfo {
  const char *name;
  UopClass cls;
  uint8_t nsrc;         ///< GPR sources; the third travels in dst_arch/phys_dst
  bool gdst, pread, pwrite;
  int8_t base_src;      ///< memory: which source is the window base
  int8_t data_src;      ///< store: which source is the data
};
constexpr OpInfo kOps[] = {
  {"POR",           kPredLogic, 0, false, true,  true,  -1, -1},
  {"MOVI48",        kAlu,       0, true,  false, false, -1, -1},
  {"SRD",           kAlu,       0, true,  false, false, -1, -1},
  {"LD_GLOBAL",     kLoad,      1, true,  false, false,  0, -1},
  {"MADLO",         kAlu,       3, true,  false, false, -1, -1},
  {"SETP_LT",       kAlu,       2, false, true,  true,  -1, -1},
  {"BRA_PRED",      kBranch,    0, false, true,  false, -1, -1},
  {"LD_GLOBAL_IDX", kLoad,      2, true,  false, false,  0, -1},
  {"C_ADD",         kAlu,       2, true,  false, false, -1, -1},
  {"ST_GLOBAL_IDX", kStore,     3, false, false, false,  1,  0},
  {"C_EXIT",        kExit,      0, false, false, false, -1, -1},
};
constexpr unsigned kNumOps = sizeof kOps / sizeof kOps[0];
unsigned opcodeOf(const OpInfo *o) { return unsigned(o - kOps) + 1; }
const OpInfo *opByName(const std::string &n) {
  for (const OpInfo &o : kOps) if (n == o.name) return &o;
  return nullptr;
}
const OpInfo *opByCode(unsigned c) {
  return c >= 1 && c <= kNumOps ? &kOps[c - 1] : nullptr;
}

/// req_id allocation on one hop: the lowest free id below 2^width, where the
/// width is the hop's own (CCV_P_W_REQ_*). Running out is a stall, not a
/// wrap -- a reused id would let a response match the wrong request.
class IdPool {
public:
  explicit IdPool(unsigned chan) : n_(1u << field(chan, "req_id").width) {}
  bool any() const { return used_.size() < n_; }
  unsigned take() {
    unsigned i = 0;
    while (used_.count(i)) ++i;
    used_.insert(i);
    return i;
  }
  bool release(unsigned i) { return used_.erase(i) != 0; }
  bool empty() const { return used_.empty(); }
private:
  unsigned n_;
  std::set<unsigned> used_;
};

uint64_t instrUid(uint64_t seq) { return makeUid(IdClass::kInstr, uint32_t(seq)); }
uint32_t g_unowned_txn = 0;   ///< sequence for transactions no instruction owns

void emit(uint64_t now, uint64_t uid, EventId id, Unit u, uint32_t a = 0,
          uint32_t b = 0, uint32_t c = 0) {
  traceWriter().emit(now, uid, id, uint16_t(u), a, b, c);
}

// ---- the stub base --------------------------------------------------------------

class Stub : public Block {
public:
  Stub(int inst, Kernel &k) : Block(inst), k_(k) {}

  void cycle(uint64_t now) final {
    if (!built_) build();
    now_ = now;
    for (const In &i : ins) i.rx->cycle(now);
    work();
    // Every sender is clocked exactly once a cycle, launching or not.
    for (size_t j = 0; j != outs.size(); ++j) {
      Pend &p = pend_[j];
      outs[j].tx->cycle(p.go, p.msg, p.tid);
      if (p.go) logLaunch(uint16_t(outs[j].ci->chan), p.msg, p.tid);
      p.go = false;
    }
    if (busy()) ++k_.busy;
    // A message left in a receiver is one this stub does not handle. The
    // bank's response_within_n will report it; say which, once.
    for (const In &i : ins)
      if (!i.rx->empty() && unhandled_.insert(i.ci->chan).second)
        k_.fail("%s: nothing consumes %s", kind(), kChans[i.ci->chan].name);
  }

protected:
  virtual void work() = 0;
  virtual bool busy() const { return false; }
  virtual const char *kind() const = 0;

  bool can(unsigned chan, unsigned slot, unsigned inst = 0) {
    const int j = outIdx(chan, slot, inst);
    return !pend_[j].go && outs[j].tx->canSend();
  }
  void send(unsigned chan, unsigned slot, const Bits &msg, uint64_t tid,
            unsigned inst = 0) {
    const int j = outIdx(chan, slot, inst);
    if (pend_[j].go || !outs[j].tx->canSend()) {
      std::fprintf(stderr, "%s: send on %s slot %u without a credit\n", kind(),
                   kChans[chan].name, slot);
      std::abort();
    }
    pend_[j] = {true, msg, tid};
  }
  bool has(unsigned chan, unsigned slot, unsigned inst = 0) {
    return !rx(chan, slot, inst).empty();
  }
  /// Consume the oldest message on a slot, checking its id class.
  Receiver::Msg take(unsigned chan, unsigned slot, unsigned inst = 0) {
    Receiver &r = rx(chan, slot, inst);
    Receiver::Msg m = r.front();
    r.pop();
    ++k_.rx_per_chan[chan];
    const ChanDesc &cd = kChans[chan];
    if (!((cd.id_classes >> unsigned(uidClass(m.tid))) & 1u)) {
      ++k_.class_violations;
      k_.fail("%s carries id class %u, not in its set", cd.name,
              unsigned(uidClass(m.tid)));
    }
    return m;
  }
  const Record *rec(uint64_t tid, const char *where) {
    const Record *r = uidClass(tid) == IdClass::kNone
                          ? nullptr : k_.orc.bySeq(uidSeq(tid));
    if (!r) k_.fail("%s: no oracle record for identity %016llx", where,
                    (unsigned long long)tid);
    return r;
  }

  Kernel &k_;
  uint64_t now_ = 0;

private:
  Receiver &rx(unsigned chan, unsigned slot, unsigned inst) {
    auto it = in_.find({chan, inst, slot});
    if (it == in_.end()) {
      std::fprintf(stderr, "%s: no input %s[%u] slot %u\n", kind(),
                   kChans[chan].name, inst, slot);
      std::abort();
    }
    return *ins[it->second].rx;
  }
  int outIdx(unsigned chan, unsigned slot, unsigned inst) {
    auto it = out_.find({chan, inst, slot});
    if (it == out_.end()) {
      std::fprintf(stderr, "%s: no output %s[%u] slot %u\n", kind(),
                   kChans[chan].name, inst, slot);
      std::abort();
    }
    return it->second;
  }
  void build() {
    for (size_t j = 0; j != outs.size(); ++j)
      out_[{outs[j].ci->chan, outs[j].ci->inst, outs[j].slot}] = int(j);
    for (size_t j = 0; j != ins.size(); ++j)
      in_[{ins[j].ci->chan, ins[j].ci->inst, ins[j].slot}] = int(j);
    pend_.resize(outs.size());
    built_ = true;
  }

  struct Pend { bool go = false; Bits msg; uint64_t tid = 0; };
  bool built_ = false;
  std::map<std::tuple<unsigned, unsigned, unsigned>, int> out_, in_;
  std::vector<Pend> pend_;
  std::set<unsigned> unhandled_;
};

/// A queued outbound message: slot, payload, identity.
struct Q { unsigned slot; Bits msg; uint64_t tid; };

// ---- testbench memory: the far end of EXTERNAL ---------------------------------

class Testbench : public Stub {
public:
  Testbench(int inst, Kernel &k) : Stub(inst, k) {
    for (size_t i = 0; i != k.orc.code.size(); ++i)
      k.mem[k.orc.code_base + i] = k.orc.code[i];
    for (auto &w : k.orc.init_mem)
      for (unsigned b = 0; b != 4; ++b)
        k.mem[w.first + b] = uint8_t(w.second >> (8 * b));
  }
  const char *kind() const override { return "testbench"; }

private:
  static constexpr uint64_t kLatency = 10;   // placeholder DRAM
  struct P { uint64_t due; Bits msg; uint64_t tid; };
  std::deque<P> q_;

  void work() override {
    const Ch &c = ch();
    while (has(c.exb_ext, 0)) {
      Receiver::Msg m = take(c.exb_ext, 0);
      const unsigned op = unsigned(m.payload.get(kTlOp, 3));
      const uint64_t addr = m.payload.get(kTlAddr, 48);
      Bits r = msgOf(c.ext_exb);
      r.set(kTlInSrc, kTlSrcW, m.payload.get(kTlSrc, kTlSrcW));
      if (addr % kLine) k_.fail("testbench: unaligned line address %llx",
                                (unsigned long long)addr);
      if (op == kTlGet) {
        Line l{};
        for (unsigned k = 0; k != kLine; ++k) {
          auto it = k_.mem.find(addr + k);
          l[k] = it == k_.mem.end() ? 0 : it->second;
        }
        r.set(kTlInOp, 3, kTlAckData);
        putLine(r, kTlInData, l);
      } else if (op == kTlPutFull) {
        const Line l = getLine(m.payload, kTlData);
        for (unsigned k = 0; k != kLine; ++k)
          if (m.payload.bit(kTlMask + k)) k_.mem[addr + k] = l[k];
        r.set(kTlInOp, 3, kTlAck);
      } else {
        k_.fail("testbench: unknown link opcode %u", op);
        continue;
      }
      q_.push_back({now_ + kLatency, r, m.tid});
    }
    if (!q_.empty() && q_.front().due <= now_ && can(c.ext_exb, 0)) {
      send(c.ext_exb, 0, q_.front().msg, q_.front().tid);
      q_.pop_front();
    }
  }
  bool busy() const override { return !q_.empty(); }
};

// ---- EXB: the core's edge ----------------------------------------------------------

class Exb : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "exb"; }

private:
  std::deque<Q> out_, in_;
  bool corrupted_ = false;

  void work() override {
    const Ch &c = ch();
    if (has(c.mlc_exb, 0)) {
      Receiver::Msg m = take(c.mlc_exb, 0);
      Bits t = msgOf(c.exb_ext);
      const bool wr = get(m.payload, c.mlc_exb, "coh_op") == kCohWrite;
      t.set(kTlOp, 3, wr ? kTlPutFull : kTlGet);
      t.set(kTlSrc, kTlSrcW, get(m.payload, c.mlc_exb, "req_id"));
      t.set(kTlAddr, 48, get(m.payload, c.mlc_exb, "phys_addr"));
      if (wr) {
        // mlc_exb_req has no byte mask: a write is always a whole line.
        for (unsigned k = 0; k != kLine; ++k) t.setBit(kTlMask + k, true);
        putLine(t, kTlData,
                getLine(m.payload, field(c.mlc_exb, "writeback_data").lsb));
      }
      out_.push_back({0, t, m.tid});
    }
    if (has(c.ext_exb, 0)) {
      Receiver::Msg m = take(c.ext_exb, 0);
      Bits r = msgOf(c.exb_mlc);
      putLine(r, field(c.exb_mlc, "line_data").lsb, getLine(m.payload, kTlInData));
      put(r, c.exb_mlc, "req_id", m.payload.get(kTlInSrc, kTlSrcW));
      put(r, c.exb_mlc, "probe_type", 0);          // a response, not a probe
      if (k_.brk == "corrupt-req-id" && !corrupted_) {
        put(r, c.exb_mlc, "req_id", get(r, c.exb_mlc, "req_id") ^ 1);
        corrupted_ = true;
      }
      put(r, c.exb_mlc, "miss", 1);
      in_.push_back({0, r, m.tid});
    }
    if (!out_.empty() && can(c.exb_ext, 0)) {
      send(c.exb_ext, 0, out_.front().msg, out_.front().tid);
      out_.pop_front();
    }
    if (!in_.empty() && can(c.exb_mlc, 0)) {
      send(c.exb_mlc, 0, in_.front().msg, in_.front().tid);
      in_.pop_front();
    }
  }
  bool busy() const override { return !out_.empty() || !in_.empty(); }
};

// ---- MLC: no cache yet; forwards, and matches responses in order ------------------

class Mlc : public Stub {
public:
  Mlc(int inst, Kernel &k) : Stub(inst, k), ids_(ch().mlc_exb) {}
  const char *kind() const override { return "mlc"; }

private:
  enum Who { kDcu, kFet };
  /// What an EXB-side req_id stands for: who asked, and under which of
  /// THEIR ids -- each hop has its own id space.
  struct Owner { Who who; unsigned their_id; };
  struct R { Owner o; Bits msg; uint64_t tid; };
  std::deque<R> to_exb_;
  IdPool ids_;
  std::map<unsigned, Owner> owner_;   ///< by req_id toward EXB
  std::deque<Q> to_dcu_, to_fet_;

  void work() override {
    const Ch &c = ch();
    if (has(c.dcu_mlc, 0)) {
      Receiver::Msg m = take(c.dcu_mlc, 0);
      Bits e = msgOf(c.mlc_exb);
      put(e, c.mlc_exb, "phys_addr", get(m.payload, c.dcu_mlc, "phys_addr"));
      put(e, c.mlc_exb, "size", kSizeLine);
      put(e, c.mlc_exb, "coh_op", get(m.payload, c.dcu_mlc, "coh_op"));
      put(e, c.mlc_exb, "core_id", get(m.payload, c.dcu_mlc, "core_id"));
      putLine(e, field(c.mlc_exb, "writeback_data").lsb,
              getLine(m.payload, field(c.dcu_mlc, "writeback_data").lsb));
      to_exb_.push_back({{kDcu, unsigned(get(m.payload, c.dcu_mlc, "req_id"))}, e, m.tid});
    }
    if (has(c.fet_mlc, 0)) {
      Receiver::Msg m = take(c.fet_mlc, 0);
      Bits e = msgOf(c.mlc_exb);
      put(e, c.mlc_exb, "phys_addr", get(m.payload, c.fet_mlc, "phys_addr"));
      put(e, c.mlc_exb, "size", kSizeLine);
      put(e, c.mlc_exb, "coh_op", kCohRead);
      to_exb_.push_back({{kFet, unsigned(get(m.payload, c.fet_mlc, "req_id"))}, e, m.tid});
    }
    if (!to_exb_.empty() && ids_.any() && can(c.mlc_exb, 0)) {
      R &r = to_exb_.front();
      const unsigned id = ids_.take();
      put(r.msg, c.mlc_exb, "req_id", id);
      owner_[id] = r.o;
      send(c.mlc_exb, 0, r.msg, r.tid);
      to_exb_.pop_front();
    }
    if (has(c.exb_mlc, 0)) {
      Receiver::Msg m = take(c.exb_mlc, 0);
      const unsigned id = unsigned(get(m.payload, c.exb_mlc, "req_id"));
      auto it = owner_.find(id);
      if (get(m.payload, c.exb_mlc, "probe_type") != 0) {
        k_.fail("mlc: an inbound probe -- not modelled in S1");
      } else if (it == owner_.end()) {
        k_.fail("mlc: a response for req_id %u, which is not outstanding", id);
      } else {
        const Line l = getLine(m.payload, field(c.exb_mlc, "line_data").lsb);
        if (it->second.who == kDcu) {
          Bits r = msgOf(c.mlc_dcu);
          put(r, c.mlc_dcu, "req_id", it->second.their_id);
          putLine(r, field(c.mlc_dcu, "line_data").lsb, l);
          put(r, c.mlc_dcu, "miss", 1);
          to_dcu_.push_back({0, r, m.tid});
        } else {
          Bits r = msgOf(c.mlc_fet);
          put(r, c.mlc_fet, "req_id", it->second.their_id);
          putLine(r, field(c.mlc_fet, "line_data").lsb, l);
          to_fet_.push_back({0, r, m.tid});
        }
        owner_.erase(it);
        ids_.release(id);
      }
    }
    if (!to_dcu_.empty() && can(c.mlc_dcu, 0)) {
      send(c.mlc_dcu, 0, to_dcu_.front().msg, to_dcu_.front().tid);
      to_dcu_.pop_front();
    }
    if (!to_fet_.empty() && can(c.mlc_fet, 0)) {
      send(c.mlc_fet, 0, to_fet_.front().msg, to_fet_.front().tid);
      to_fet_.pop_front();
    }
  }
  bool busy() const override {
    return !to_exb_.empty() || !owner_.empty() || !to_dcu_.empty() ||
           !to_fet_.empty();
  }
};

// ---- DCU: no cache yet; a write is read-modify-write of the line -----------------
//
// dcu_mlc_req carries no byte mask, so a partial store cannot go below DCU
// as it arrived: DCU reads the line, merges the bytes the mask selects, and
// writes the whole line. One request at a time.

class Dcu : public Stub {
public:
  Dcu(int inst, Kernel &k) : Stub(inst, k), ids_(ch().dcu_mlc) {}
  const char *kind() const override { return "dcu"; }

private:
  struct Op { unsigned slot; Bits req; uint64_t tid; };
  std::deque<Op> q_;
  enum { kIdle, kWaitLine, kWaitAck } st_ = kIdle;
  Op cur_{0, Bits(), 0};
  IdPool ids_;
  unsigned mlc_id_ = 0;              ///< the one request to MLC outstanding
  std::deque<Q> to_mlc_, to_miu_;

  /// A response to MIU answers its request by MIU's own req_id.
  Bits miuRsp() {
    Bits r = msgOf(ch().dcu_miu);
    put(r, ch().dcu_miu, "req_id", get(cur_.req, ch().miu_dcu, "req_id"));
    return r;
  }

  void mlcReq(unsigned coh, uint64_t pa, const Line *data) {
    const Ch &c = ch();
    Bits r = msgOf(c.dcu_mlc);
    put(r, c.dcu_mlc, "phys_addr", pa);
    put(r, c.dcu_mlc, "coh_op", coh);
    mlc_id_ = ids_.take();
    put(r, c.dcu_mlc, "req_id", mlc_id_);
    if (data) putLine(r, field(c.dcu_mlc, "writeback_data").lsb, *data);
    to_mlc_.push_back({0, r, cur_.tid});
  }

  void work() override {
    const Ch &c = ch();
    for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s)
      while (has(c.miu_dcu, s)) {
        Receiver::Msg m = take(c.miu_dcu, s);
        q_.push_back({s, m.payload, m.tid});
      }
    if (has(c.mlc_dcu, 0)) {
      Receiver::Msg m = take(c.mlc_dcu, 0);
      const bool wr = get(cur_.req, c.miu_dcu, "coh_op") == kCohWrite;
      const unsigned id = unsigned(get(m.payload, c.mlc_dcu, "req_id"));
      if (st_ == kIdle || id != mlc_id_ || !ids_.release(id))
        k_.fail("dcu: MLC answered req_id %u, which is not outstanding", id);
      Bits r = miuRsp();
      if (st_ == kWaitLine && !wr) {
        putLine(r, field(c.dcu_miu, "read_data").lsb,
                getLine(m.payload, field(c.mlc_dcu, "line_data").lsb));
        to_miu_.push_back({cur_.slot, r, cur_.tid});
        st_ = kIdle;
      } else if (st_ == kWaitLine) {
        Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
        const Line w = getLine(cur_.req, field(c.miu_dcu, "write_data").lsb);
        const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
        for (unsigned k = 0; k != kLine; ++k)
          if (cur_.req.bit(mlsb + k)) l[k] = w[k];
        mlcReq(kCohWrite, get(cur_.req, c.miu_dcu, "phys_addr"), &l);
        st_ = kWaitAck;
      } else if (st_ == kWaitAck) {
        to_miu_.push_back({cur_.slot, r, cur_.tid});   // the write's ack
        st_ = kIdle;
      } else {
        k_.fail("dcu: a line from MLC it did not ask for");
      }
    }
    if (st_ == kIdle && !q_.empty()) {
      cur_ = q_.front();
      q_.pop_front();
      mlcReq(kCohRead, get(cur_.req, c.miu_dcu, "phys_addr"), nullptr);
      st_ = kWaitLine;
    }
    if (!to_mlc_.empty() && can(c.dcu_mlc, 0)) {
      send(c.dcu_mlc, 0, to_mlc_.front().msg, to_mlc_.front().tid);
      to_mlc_.pop_front();
    }
    for (auto it = to_miu_.begin(); it != to_miu_.end();)
      if (can(c.dcu_miu, it->slot)) {
        send(c.dcu_miu, it->slot, it->msg, it->tid);
        it = to_miu_.erase(it);
      } else {
        ++it;
      }
  }
  bool busy() const override {
    return !q_.empty() || st_ != kIdle || !to_mlc_.empty() || !to_miu_.empty();
  }
};

// ---- MIU -------------------------------------------------------------------------

class Miu : public Stub {
public:
  Miu(int inst, Kernel &k) : Stub(inst, k), ids_(ch().miu_dcu) {}
  const char *kind() const override { return "miu"; }

private:
  struct Memop { unsigned slot; Bits msg; };
  struct Addr { unsigned slot; Bits msg; uint64_t tid; };
  struct LineReq { uint64_t line; Line data{}; std::array<bool, kLine> mask{}; uint16_t sub; };
  struct Job {
    bool store = false;
    unsigned tag = 0, memop_slot = 0, addr_slot = 0;
    uint32_t active = 0;             ///< lanes that may access memory
    uint64_t tid = 0;
    std::array<uint64_t, kLanes> addr{};
    std::vector<LineReq> lines;
    unsigned next = 0, back = 0;     ///< lines requested / answered
    std::map<uint64_t, Line> got;
  };

  std::map<unsigned, Memop> memop_;
  std::map<unsigned, Addr> addr_;
  std::deque<unsigned> order_;               ///< memops, as OOE issued them
  std::map<unsigned, Job> stores_;           ///< awaiting commit, by rob tag
  std::deque<Job> committed_;
  bool active_ = false;
  Job job_;
  bool dropped_ = false;
  IdPool ids_;
  std::map<unsigned, uint64_t> outstanding_;   ///< line, by req_id to DCU
  std::deque<Q> to_rcu_, to_ooe_, to_dcu_, to_fet_;

  void work() override {
    const Ch &c = ch();
    if (has(c.fet_miu, 0)) {
      // Identity translation: the page table is not modelled yet.
      Receiver::Msg m = take(c.fet_miu, 0);
      Bits r = msgOf(c.miu_fet);
      put(r, c.miu_fet, "itlb_refill", get(m.payload, c.fet_miu, "virtual_page"));
      to_fet_.push_back({0, r, m.tid});
    }
    if (has(c.rau_miu, 0)) take(c.rau_miu, 0);   // CTA config: nothing reads it yet
    for (unsigned s = 0; s != kChans[c.ooe_miu].rate; ++s)
      while (has(c.ooe_miu, s)) {
        Receiver::Msg m = take(c.ooe_miu, s);
        const unsigned tag = unsigned(get(m.payload, c.ooe_miu, "rob_tag"));
        memop_[tag] = {s, m.payload};
        order_.push_back(tag);
      }
    for (unsigned s = 0; s != kChans[c.rcu_miu].rate; ++s)
      while (has(c.rcu_miu, s)) {
        Receiver::Msg m = take(c.rcu_miu, s);
        addr_[unsigned(get(m.payload, c.rcu_miu, "rob_tag"))] = {s, m.payload, m.tid};
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
          if (k_.brk == "drop-store" && !dropped_) dropped_ = true;
          else committed_.push_back(it->second);
        }
        stores_.erase(it);
      }
    for (unsigned s = 0; s != kChans[c.dcu_miu].rate; ++s)
      while (has(c.dcu_miu, s)) {
        Receiver::Msg m = take(c.dcu_miu, s);
        // Matched by req_id, not by slot or arrival order: DCU may answer
        // four outstanding requests in any order.
        const unsigned id = unsigned(get(m.payload, c.dcu_miu, "req_id"));
        auto o = outstanding_.find(id);
        if (!active_ || o == outstanding_.end()) {
          k_.fail("miu: a DCU response for req_id %u, which is not outstanding", id);
          continue;
        }
        const uint64_t line = o->second;
        outstanding_.erase(o);
        ids_.release(id);
        job_.got[line] = getLine(m.payload, field(c.dcu_miu, "read_data").lsb);
        ++job_.back;
        emit(now_, m.tid, EV_MEM_RSP, UNIT_MIU, uint32_t(line),
             uint32_t(line >> 32), job_.store ? kCohWrite : kCohRead);
      }

    if (!active_) start();
    if (active_) advance();

    auto drain = [&](std::deque<Q> &q, unsigned chan) {
      for (auto it = q.begin(); it != q.end();)
        if (can(chan, it->slot)) { send(chan, it->slot, it->msg, it->tid); it = q.erase(it); }
        else ++it;
    };
    drain(to_fet_, c.miu_fet);
    drain(to_rcu_, c.miu_rcu);
    drain(to_ooe_, c.miu_ooe);
    drain(to_dcu_, c.miu_dcu);
  }

  /// Committed stores first (they are older than anything still issuing),
  /// then the oldest memop whose address has arrived.
  void start() {
    const Ch &c = ch();
    if (!committed_.empty()) {
      job_ = committed_.front();
      committed_.pop_front();
      active_ = true;
      return;
    }
    if (order_.empty()) return;
    const unsigned tag = order_.front();
    auto a = addr_.find(tag);
    if (a == addr_.end()) return;
    const Memop &mo = memop_[tag];
    Job j;
    j.tag = tag;
    j.store = get(mo.msg, c.ooe_miu, "mem_op") == kMemStore;
    j.memop_slot = mo.slot;
    j.addr_slot = a->second.slot;
    j.tid = a->second.tid;
    const Bits &am = a->second.msg;
    // The mask arrives twice, from OOE and from RCU (the response's safe
    // default); the two describe one operation and must agree.
    j.active = uint32_t(get(am, c.rcu_miu, "active_mask"));
    if (uint32_t(get(mo.msg, c.ooe_miu, "active_mask")) != j.active)
      k_.fail("miu: rob tag %u active_mask differs between OOE and RCU", tag);
    const uint64_t base = get(am, c.rcu_miu, "base");
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l) & 1u)
        j.addr[l] = base + getLane(am, c.rcu_miu, "index_per_lane", l);
    // Lines touched by ACTIVE lanes, in first-touch order; four bytes per
    // lane (32-bit only). An inactive lane's address is never looked at.
    std::map<uint64_t, size_t> at;
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!((j.active >> l) & 1u)) continue;
      const uint64_t line = j.addr[l] / kLine * kLine;
      if (!at.count(line)) {
        at[line] = j.lines.size();
        j.lines.push_back({line, {}, {}, uint16_t(j.lines.size())});
      }
      if (j.store) {
        LineReq &lr = j.lines[at[line]];
        const uint32_t v = getLane(am, c.rcu_miu, "store_data", l);
        for (unsigned b = 0; b != 4; ++b) {
          const unsigned off = unsigned(j.addr[l] % kLine) + b;
          lr.data[off] = uint8_t(v >> (8 * b));
          lr.mask[off] = true;
        }
      }
    }
    check(j, am);
    order_.pop_front();
    memop_.erase(tag);
    addr_.erase(a);
    if (j.store) {
      // Translated and checked; the write waits for retirement.
      stores_[tag] = j;
      to_ooe_.push_back({j.memop_slot, cmpl(j), j.tid});
      return;
    }
    for (const LineReq &lr : j.lines)
      for (const auto &s : stores_)
        for (const LineReq &sl : s.second.lines)
          if (sl.line == lr.line)
            k_.fail("miu: load overlaps an uncommitted store -- forwarding is "
                    "not modelled");
    job_ = j;
    active_ = true;
  }

  /// The addresses and store data MIU computed from what it was SENT, against
  /// what ccv-sim says the instruction accessed.
  void check(const Job &j, const Bits &am) {
    const Record *r = rec(j.tid, "miu");
    if (!r) return;
    uint32_t lanes = 0;
    for (const MemAcc &a : r->mem) lanes |= 1u << a.lane;
    if (lanes != j.active || r->store != j.store) {
      k_.fail("miu: seq %llu active_mask %08x, but ccv-sim's %s touched lanes %08x",
              (unsigned long long)r->seq, j.active, r->store ? "store" : "load", lanes);
      return;
    }
    for (const MemAcc &a : r->mem) {
      if (a.addr != j.addr[a.lane] || a.bytes != 4 || a.shared)
        k_.fail("miu: seq %llu lane %u address %llx, oracle %llx",
                (unsigned long long)r->seq, a.lane,
                (unsigned long long)j.addr[a.lane], (unsigned long long)a.addr);
      if (j.store && getLane(am, ch().rcu_miu, "store_data", a.lane) != a.val)
        k_.fail("miu: seq %llu lane %u store data %08x, oracle %08x",
                (unsigned long long)r->seq, a.lane,
                getLane(am, ch().rcu_miu, "store_data", a.lane), a.val);
    }
  }

  Bits cmpl(const Job &j) {
    const Ch &c = ch();
    Bits m = msgOf(c.miu_ooe);
    put(m, c.miu_ooe, "rob_tag", j.tag);
    put(m, c.miu_ooe, "lane_mask", j.active);
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l) & 1u) { put(m, c.miu_ooe, "address", j.addr[l]); break; }
    put(m, c.miu_ooe, "mlc_miss", 1);
    return m;
  }

  void advance() {
    const Ch &c = ch();
    const unsigned rate = kChans[c.miu_dcu].rate;
    // Up to one line request per DCU slot per cycle.
    for (unsigned s = 0; s != rate && job_.next != job_.lines.size(); ++s) {
      if (!can(c.miu_dcu, s) || !ids_.any()) continue;
      const LineReq &lr = job_.lines[job_.next++];
      Bits r = msgOf(c.miu_dcu);
      const unsigned id = ids_.take();
      put(r, c.miu_dcu, "req_id", id);
      put(r, c.miu_dcu, "phys_addr", lr.line);
      put(r, c.miu_dcu, "size", kSizeLine);
      put(r, c.miu_dcu, "coh_op", job_.store ? kCohWrite : kCohRead);
      if (job_.store) {
        putLine(r, field(c.miu_dcu, "write_data").lsb, lr.data);
        const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
        for (unsigned k = 0; k != kLine; ++k) r.setBit(mlsb + k, lr.mask[k]);
      }
      const uint64_t tid =
          makeUid(IdClass::kTxn, uidSeq(job_.tid), lr.sub, /*owned=*/true);
      send(c.miu_dcu, s, r, tid);
      outstanding_[id] = lr.line;
      emit(now_, tid, EV_MEM_REQ, UNIT_MIU, uint32_t(lr.line),
           uint32_t(lr.line >> 32), job_.store ? kCohWrite : kCohRead);
    }
    if (job_.back != job_.lines.size()) return;
    if (!job_.store) {
      Bits d = msgOf(c.miu_rcu);
      put(d, c.miu_rcu, "rob_tag", job_.tag);
      put(d, c.miu_rcu, "active_mask", job_.active);
      const Record *r = rec(job_.tid, "miu");
      for (unsigned l = 0; l != kLanes; ++l) {
        if (!((job_.active >> l) & 1u)) continue;
        const Line &ln = job_.got[job_.addr[l] / kLine * kLine];
        const unsigned off = unsigned(job_.addr[l] % kLine);
        uint32_t v = 0;
        for (unsigned b = 0; b != 4; ++b) v |= uint32_t(ln[off + b]) << (8 * b);
        // What came back from memory, against what ccv-sim loaded.
        if (r)
          for (const MemAcc &a : r->mem)
            if (a.lane == l && a.val != v)
              k_.fail("miu: seq %llu lane %u loaded %08x, oracle %08x",
                      (unsigned long long)r->seq, l, v, a.val);
        if (k_.brk == "corrupt-load" && r && r->seq == 13 && l == 5) v ^= 1;
        putLane(d, c.miu_rcu, "load_data", l, v);
      }
      to_rcu_.push_back({job_.addr_slot, d, job_.tid});
      to_ooe_.push_back({job_.memop_slot, cmpl(job_), job_.tid});
    }
    active_ = false;
  }

  bool busy() const override {
    return active_ || !order_.empty() || !stores_.empty() ||
           !committed_.empty() || !to_rcu_.empty() || !to_ooe_.empty() ||
           !to_dcu_.empty() || !to_fet_.empty();
  }
};

// ---- LANE: one of 32; operands in, oracle result out ------------------------------

class Lane : public Stub {
public:
  Lane(int inst, Kernel &k) : Stub(inst, k), lane_(kBlkInsts[inst].index) {}
  const char *kind() const override { return "lane"; }

private:
  unsigned lane_;
  std::deque<Q> q_;

  void work() override {
    const Ch &c = ch();
    for (unsigned s = 0; s != kChans[c.rcu_lane].rate; ++s)
      while (has(c.rcu_lane, s, lane_)) {
        Receiver::Msg m = take(c.rcu_lane, s, lane_);
        Bits r = msgOf(c.lane_rcu);
        if (const Record *rc = rec(m.tid, "lane")) {
          const OpInfo *op = opByCode(unsigned(get(m.payload, c.rcu_lane, "opcode")));
          if (op != opByName(rc->op))
            k_.fail("lane %u: seq %llu opcode is not %s", lane_,
                    (unsigned long long)rc->seq, rc->op.c_str());
          // Operands: what RCU read out of its register file.
          const auto g = rc->gprUses();
          for (size_t i = 0; i != g.size() && i < 3; ++i) {
            const uint32_t got = uint32_t(m.payload.get(
                field(c.rcu_lane, "operand").lsb + 32 * unsigned(i), 32));
            if (got != g[i]->v[lane_])
              k_.fail("lane %u: seq %llu operand %zu (R%u) %08x, oracle %08x",
                      lane_, (unsigned long long)rc->seq, i, g[i]->idx, got,
                      g[i]->v[lane_]);
          }
          if (const RegVal *p = rc->predUse()) {
            const bool got = get(m.payload, c.rcu_lane, "pred_bit") != 0;
            if (got != (((p->p >> lane_) & 1u) != 0))
              k_.fail("lane %u: seq %llu predicate P%u bit wrong", lane_,
                      (unsigned long long)rc->seq, p->idx);
          }
          // The result: what ccv-sim computed (the "what", §1).
          uint32_t v = 0;
          if (const RegVal *d = rc->gprDef()) v = d->v[lane_];
          else if (const RegVal *d = rc->predDef()) v = (d->p >> lane_) & 1u;
          put(r, c.lane_rcu, "result", v);
        }
        q_.push_back({s, r, m.tid});
      }
    for (auto it = q_.begin(); it != q_.end();)
      if (can(c.lane_rcu, it->slot, lane_)) {
        send(c.lane_rcu, it->slot, it->msg, it->tid, lane_);
        it = q_.erase(it);
      } else {
        ++it;
      }
  }
  bool busy() const override { return !q_.empty(); }
};

// ---- RCU: the register file ----------------------------------------------------------

class Rcu : public Stub {
public:
  Rcu(int inst, Kernel &k) : Stub(inst, k) {
    k.gpr.assign(256, {});
    k.pred.assign(256, 0);
  }
  const char *kind() const override { return "rcu"; }

private:
  struct Alu { unsigned tag; const OpInfo *op; unsigned pdst, ppred; uint64_t tid; };
  struct Ld { unsigned slot, pdst; uint64_t tid; };
  std::array<std::deque<Alu>, 4> alu_;            ///< per issue slot: bound lanes
  std::map<unsigned, Ld> loads_;
  std::array<std::deque<std::pair<std::vector<Bits>, uint64_t>>, 4> lane_q_;
  std::deque<Q> to_ooe_, to_miu_;

  Bits done(unsigned tag) {
    Bits d = msgOf(ch().rcu_ooe);
    put(d, ch().rcu_ooe, "rob_tag", tag);
    return d;
  }

  void work() override {
    const Ch &c = ch();
    const unsigned rate = kChans[c.ooe_rcu].rate;
    for (unsigned s = 0; s != rate; ++s)
      while (has(c.ooe_rcu, s)) issue(s, take(c.ooe_rcu, s));

    // Lane results, slot by slot: all 32 lanes, or it is not lockstep.
    for (unsigned s = 0; s != rate; ++s) {
      unsigned n = 0;
      for (unsigned l = 0; l != kLanes; ++l) n += has(c.lane_rcu, s, l);
      if (n == 0) continue;
      if (n != kLanes) { k_.fail("rcu: %u of 32 lanes answered on slot %u", n, s); continue; }
      if (alu_[s].empty()) { k_.fail("rcu: lane results on slot %u for nothing", s); continue; }
      const Alu a = alu_[s].front();
      alu_[s].pop_front();
      for (unsigned l = 0; l != kLanes; ++l) {
        Receiver::Msg m = take(c.lane_rcu, s, l);
        if (m.tid != a.tid) k_.fail("rcu: lane %u slot %u answered for another instruction", l, s);
        const uint32_t v = uint32_t(get(m.payload, c.lane_rcu, "result"));
        if (a.op->gdst) k_.gpr[a.pdst][l] = v;
        if (a.op->pwrite)
          k_.pred[a.ppred] = (k_.pred[a.ppred] & ~(1u << l)) | ((v & 1u) << l);
      }
      to_ooe_.push_back({s, done(a.tag), a.tid});
    }

    for (unsigned s = 0; s != kChans[c.miu_rcu].rate; ++s)
      while (has(c.miu_rcu, s)) {
        Receiver::Msg m = take(c.miu_rcu, s);
        const unsigned tag = unsigned(get(m.payload, c.miu_rcu, "rob_tag"));
        auto it = loads_.find(tag);
        if (it == loads_.end()) { k_.fail("rcu: load data for rob tag %u, no load", tag); continue; }
        // miu_rcu_data.phys_dst has no source: nothing MIU receives names the
        // destination (open question miu_rcu_phys_dst). RCU kept it at issue.
        const unsigned pd = it->second.pdst;
        const uint32_t active = uint32_t(get(m.payload, c.miu_rcu, "active_mask"));
        for (unsigned l = 0; l != kLanes; ++l)
          if ((active >> l) & 1u)   // an inactive lane keeps its old value
            k_.gpr[pd][l] = getLane(m.payload, c.miu_rcu, "load_data", l);
        to_ooe_.push_back({it->second.slot, done(tag), it->second.tid});
        loads_.erase(it);
      }

    for (unsigned s = 0; s != rate; ++s) {
      if (lane_q_[s].empty()) continue;
      bool all = true;
      for (unsigned l = 0; l != kLanes; ++l) all = all && can(c.rcu_lane, s, l);
      if (!all) continue;     // lockstep: every lane or none
      for (unsigned l = 0; l != kLanes; ++l)
        send(c.rcu_lane, s, lane_q_[s].front().first[l], lane_q_[s].front().second, l);
      lane_q_[s].pop_front();
    }
    for (auto *q : {&to_ooe_, &to_miu_}) {
      const unsigned chan = q == &to_ooe_ ? c.rcu_ooe : c.rcu_miu;
      for (auto it = q->begin(); it != q->end();)
        if (can(chan, it->slot)) { send(chan, it->slot, it->msg, it->tid); it = q->erase(it); }
        else ++it;
    }
  }

  void issue(unsigned s, const Receiver::Msg &m) {
    const Ch &c = ch();
    const unsigned tag = unsigned(get(m.payload, c.ooe_rcu, "rob_tag"));
    const OpInfo *op = opByCode(unsigned(get(m.payload, c.ooe_rcu, "opcode")));
    if (!op) { k_.fail("rcu: unknown opcode"); return; }
    const unsigned ps = unsigned(get(m.payload, c.ooe_rcu, "phys_src"));
    const unsigned pd = unsigned(get(m.payload, c.ooe_rcu, "phys_dst"));
    const unsigned pp = unsigned(get(m.payload, c.ooe_rcu, "phys_pred"));
    // Two sources in phys_src; a third travels in phys_dst (open question
    // src_arch_vs_operand -- the accumulate reading).
    const unsigned src[3] = {ps >> 8, ps & 0xff, pd};

    if (op->cls == kLoad || op->cls == kStore) {
      Bits a = msgOf(c.rcu_miu);
      put(a, c.rcu_miu, "rob_tag", tag);
      // Issue mask AND guard. No issue mask reaches RCU (open question
      // active_lane_mask), so it is all 32 lanes -- which the oracle checks.
      const uint32_t active = op->pread ? k_.pred[pp] : 0xffffffffu;
      put(a, c.rcu_miu, "active_mask", active);
      const auto &b = k_.gpr[src[op->base_src]];
      for (unsigned l = 1; l != kLanes; ++l)
        if (b[l] != b[0]) { k_.fail("rcu: window base differs across lanes; rcu_miu_addr.base is scalar"); break; }
      const uint64_t base = uint64_t(b[0]) << 16;   // .global window, §5.1
      put(a, c.rcu_miu, "base", base);
      // SUBSTITUTION (open question agu_immediate): no displacement or scale
      // reaches RCU, so each lane's offset comes from the oracle record.
      if (const Record *r = rec(m.tid, "rcu"))
        for (const MemAcc &acc : r->mem)
          putLane(a, c.rcu_miu, "index_per_lane", acc.lane, uint32_t(acc.addr - base));
      if (op->cls == kStore)
        for (unsigned l = 0; l != kLanes; ++l)
          putLane(a, c.rcu_miu, "store_data", l, k_.gpr[src[op->data_src]][l]);
      to_miu_.push_back({s, a, m.tid});
      if (op->cls == kStore) to_ooe_.push_back({s, done(tag), m.tid});
      else loads_[tag] = {s, pd, m.tid};
      return;
    }
    std::vector<Bits> lanes;
    for (unsigned l = 0; l != kLanes; ++l) {
      Bits o = msgOf(c.rcu_lane);
      put(o, c.rcu_lane, "opcode", opcodeOf(op));
      for (unsigned i = 0; i != op->nsrc; ++i)
        o.set(field(c.rcu_lane, "operand").lsb + 32 * i, 32, k_.gpr[src[i]][l]);
      if (op->pread) put(o, c.rcu_lane, "pred_bit", (k_.pred[pp] >> l) & 1u);
      put(o, c.rcu_lane, "section_en", 1);
      lanes.push_back(o);
    }
    lane_q_[s].push_back({lanes, m.tid});
    alu_[s].push_back({tag, op, pd, pp, m.tid});
  }

  bool busy() const override {
    for (unsigned s = 0; s != 4; ++s)
      if (!alu_[s].empty() || !lane_q_[s].empty()) return true;
    return !loads_.empty() || !to_ooe_.empty() || !to_miu_.empty();
  }
};

// ---- OOE: in-order issue with a scoreboard, in-order retire ------------------------

class Ooe : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "ooe"; }

private:
  struct E {
    uint64_t tid, pc;
    unsigned tag, warp;
    const OpInfo *op;
    unsigned src[3], dst, pidx;     ///< arch; src[2]/dst share dst_arch
    bool issued = false, rcu = false, miu = false, committed = false;
    bool complete() const {
      const bool mem = op->cls == kLoad || op->cls == kStore;
      return op->cls == kExit ? issued : issued && rcu && (!mem || miu);
    }
  };
  std::deque<E> rob_;
  unsigned next_tag_ = 0;
  unsigned prf_base_[32] = {};
  static constexpr unsigned kRob = 128;

  void work() override {
    const Ch &c = ch();
    if (has(c.rau_ooe, 0)) {
      Receiver::Msg m = take(c.rau_ooe, 0);
      const unsigned w = unsigned(get(m.payload, c.rau_ooe, "warp_id"));
      prf_base_[w] = unsigned(get(m.payload, c.rau_ooe, "prf_base"));
      if (w == 0) k_.prf_base = prf_base_[w];
    }
    // Uops: oldest first by (arrival, slot) -- all landed this cycle, so slot
    // order is age order; the key (warp_id) keeps each warp's own order.
    for (unsigned s = 0; s != kChans[c.dec_ooe].rate; ++s)
      while (has(c.dec_ooe, s)) dispatch(take(c.dec_ooe, s));
    for (unsigned s = 0; s != kChans[c.rcu_ooe].rate; ++s)
      while (has(c.rcu_ooe, s)) {
        Receiver::Msg m = take(c.rcu_ooe, s);
        if (E *e = byTag(unsigned(get(m.payload, c.rcu_ooe, "rob_tag")))) e->rcu = true;
        else k_.fail("ooe: done for a tag not in the ROB");
      }
    for (unsigned s = 0; s != kChans[c.miu_ooe].rate; ++s)
      while (has(c.miu_ooe, s)) {
        Receiver::Msg m = take(c.miu_ooe, s);
        if (get(m.payload, c.miu_ooe, "status") != 0) k_.fail("ooe: memory op failed");
        if (E *e = byTag(unsigned(get(m.payload, c.miu_ooe, "rob_tag")))) e->miu = true;
        else k_.fail("ooe: completion for a tag not in the ROB");
      }
    issueOne();
    retireOne();
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
    e.op = opByCode(unsigned(get(u, c.dec_ooe, "opcode")));
    if (!e.op || get(u, c.dec_ooe, "decode_fault")) {
      k_.fail("ooe: a uop it cannot execute");
      return;
    }
    if (rob_.size() == kRob) k_.fail("ooe: ROB overflow");
    const unsigned sa = unsigned(get(u, c.dec_ooe, "src_arch"));
    e.src[0] = sa >> 4;
    e.src[1] = sa & 15;
    e.src[2] = e.dst = unsigned(get(u, c.dec_ooe, "dst_arch"));
    e.pidx = unsigned(get(u, c.dec_ooe, "pred_reg"));
    e.tag = next_tag_;
    next_tag_ = (next_tag_ + 1) % kRob;
    emit(now_, e.tid, EV_DISPATCH, UNIT_OOE, e.warp, e.tag);
    rob_.push_back(e);
  }

  /// Registers an entry reads and writes, as (kind, index) pairs.
  static void regs(const E &e, std::vector<unsigned> &rd, std::vector<unsigned> &wr) {
    for (unsigned i = 0; i != e.op->nsrc; ++i) rd.push_back(e.src[i]);
    if (e.op->pread) rd.push_back(100 + e.pidx);
    if (e.op->gdst) wr.push_back(e.dst);
    if (e.op->pwrite) wr.push_back(100 + e.pidx);
  }

  void issueOne() {
    const Ch &c = ch();
    size_t i = 0;
    while (i != rob_.size() && rob_[i].issued) ++i;
    if (i == rob_.size()) return;
    E &e = rob_[i];
    std::vector<unsigned> rd, wr;
    regs(e, rd, wr);
    const bool mem = e.op->cls == kLoad || e.op->cls == kStore;
    for (size_t j = 0; j != i; ++j) {
      if (rob_[j].complete()) continue;
      std::vector<unsigned> ord, owr;
      regs(rob_[j], ord, owr);
      for (unsigned w : owr) {
        for (unsigned r : rd) if (r == w) return;    // RAW
        for (unsigned x : wr) if (x == w) return;    // WAW
      }
      const bool omem = rob_[j].op->cls == kLoad || rob_[j].op->cls == kStore;
      if (mem && omem) return;                       // memory in order
      if (e.op->cls == kExit) return;                // exit waits for all
    }
    if (e.op->cls == kExit) { e.issued = true; return; }
    const unsigned slot = e.tag % kChans[c.ooe_rcu].rate;
    if (!can(c.ooe_rcu, slot) || (mem && !can(c.ooe_miu, slot))) return;
    const unsigned pb = prf_base_[e.warp];
    Bits is = msgOf(c.ooe_rcu);
    put(is, c.ooe_rcu, "rob_tag", e.tag);
    put(is, c.ooe_rcu, "warp_id", e.warp);
    put(is, c.ooe_rcu, "phys_src", ((pb + e.src[0]) << 8) | (pb + e.src[1]));
    put(is, c.ooe_rcu, "phys_dst", pb + e.dst);
    put(is, c.ooe_rcu, "phys_pred", physPred(e.warp, e.pidx));
    put(is, c.ooe_rcu, "opcode", opcodeOf(e.op));
    send(c.ooe_rcu, slot, is, e.tid);
    if (mem) {
      Bits mo = msgOf(c.ooe_miu);
      put(mo, c.ooe_miu, "rob_tag", e.tag);
      put(mo, c.ooe_miu, "warp_id", e.warp);
      put(mo, c.ooe_miu, "mem_op", e.op->cls == kStore ? kMemStore : kMemLoad);
      // OOE has the issue mask but not predicate values (open question
      // active_lane_mask). Unpredicated and undiverged, that is all lanes.
      put(mo, c.ooe_miu, "active_mask", e.op->pread ? 0u : 0xffffffffu);
      send(c.ooe_miu, slot, mo, e.tid);
    }
    e.issued = true;
    emit(now_, e.tid, EV_ISSUE, UNIT_OOE, e.warp, slot, e.tag);
  }

  void retireOne() {
    const Ch &c = ch();
    if (rob_.empty() || !rob_.front().complete()) return;
    E &e = rob_.front();
    if (e.op->cls == kStore && !e.committed) {
      const unsigned slot = e.tag % kChans[c.ooe_ret].rate;
      if (!can(c.ooe_ret, slot)) return;
      Bits r = msgOf(c.ooe_ret);
      put(r, c.ooe_ret, "rob_tag", e.tag);
      put(r, c.ooe_ret, "commit_or_discard", 1);
      send(c.ooe_ret, slot, r, e.tid);
      e.committed = true;
    }
    // No active-lane mask reaches OOE (open question active_lane_mask), so
    // every group retires with all 32 lanes.
    emit(now_, e.tid, EV_RETIRE, UNIT_OOE, e.warp, e.tag, 0xffffffffu);
    ++k_.retired;
    k_.retire_order.push_back(uidSeq(e.tid));
    if (e.op->cls == kExit) k_.exited = true;
    rob_.pop_front();
  }

  bool busy() const override { return !rob_.empty(); }
};

// ---- DEC ---------------------------------------------------------------------------

class Dec : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "dec"; }

private:
  std::deque<std::pair<Bits, uint64_t>> q_;

  void work() override {
    const Ch &c = ch();
    // fet_dec_instr is ordered per binding group; everything taken this
    // cycle landed this cycle, so ascending slot within a group is age order.
    for (unsigned s = 0; s != kChans[c.fet_dec].rate; ++s)
      while (has(c.fet_dec, s)) decode(take(c.fet_dec, s));
    // Up to one uop per slot, in age order into ascending slots, so OOE can
    // recover the order from (arrival, slot).
    for (unsigned s = 0; s != kChans[c.dec_ooe].rate && !q_.empty(); ++s) {
      if (!can(c.dec_ooe, s)) break;
      send(c.dec_ooe, s, q_.front().first, q_.front().second);
      q_.pop_front();
    }
  }

  void decode(const Receiver::Msg &m) {
    const Ch &c = ch();
    const Bits &f = m.payload;
    const Record *r = rec(m.tid, "dec");
    if (!r) return;
    const unsigned len = 2 * (unsigned(get(f, c.fet_dec, "length")) + 1);
    const uint64_t pc = get(f, c.fet_dec, "pc");
    const uint64_t word = get(f, c.fet_dec, "instr");
    // The bytes FETCH delivered -- fetched from testbench memory through the
    // ifill path -- against the bytes ccv-sim executed.
    bool same = len == r->size && pc == r->pc;
    for (unsigned b = 0; b != r->size && same; ++b)
      same = uint8_t(word >> (8 * b)) == r->bytes[b];
    if (!same)
      k_.fail("dec: seq %llu fetched %u bytes at %llx that are not what ccv-sim ran",
              (unsigned long long)r->seq, len, (unsigned long long)pc);
    if (get(f, c.fet_dec, "fetch_fault")) k_.fail("dec: fetch fault");
    emit(now_, m.tid, EV_DECODE, UNIT_DEC, uint32_t(pc), uint32_t(pc >> 32));

    // Decode itself is the oracle's: which registers the instruction reads
    // and writes. The table checks the record has the shape the uop can hold.
    const OpInfo *op = opByName(r->op);
    Bits u = msgOf(c.dec_ooe);
    put(u, c.dec_ooe, "warp_id", get(f, c.fet_dec, "warp_id"));
    put(u, c.dec_ooe, "pc", pc);
    if (!op) {
      k_.fail("dec: %s is not in the skeleton's opcode table", r->op.c_str());
      put(u, c.dec_ooe, "decode_fault", 1);
      q_.push_back({u, m.tid});
      return;
    }
    const auto g = r->gprUses();
    const RegVal *gd = r->gprDef(), *pu = r->predUse(), *pd = r->predDef();
    if (g.size() != op->nsrc || bool(gd) != op->gdst || bool(pu) != op->pread ||
        bool(pd) != op->pwrite)
      k_.fail("dec: seq %llu %s has an operand shape the table does not",
              (unsigned long long)r->seq, op->name);
    unsigned dst = gd ? gd->idx : 0;
    if (g.size() == 3) {
      // The third source rides in dst_arch: only if it IS the destination
      // (accumulate) or there is none (store).
      if (gd && gd->idx != g[2]->idx)
        k_.fail("dec: seq %llu needs three sources and a different destination; "
                "the uop holds two plus dst_arch", (unsigned long long)r->seq);
      dst = g[2]->idx;
    }
    if (pu && pd && pu->idx != pd->idx)
      k_.fail("dec: seq %llu reads P%u and writes P%u; pred_reg holds one "
              "(open question pred_src_and_dst)", (unsigned long long)r->seq,
              pu->idx, pd->idx);
    const unsigned pidx = pu ? pu->idx : pd ? pd->idx : 0;
    put(u, c.dec_ooe, "uop_class", op->cls);
    put(u, c.dec_ooe, "opcode", opcodeOf(op));
    put(u, c.dec_ooe, "src_arch",
        ((g.size() > 0 ? g[0]->idx : 0) << 4) | (g.size() > 1 ? g[1]->idx : 0));
    put(u, c.dec_ooe, "dst_arch", dst);
    // pred_reg is an index (CCV_W_ARCH_PRED); whether it is read, written
    // or both is the opcode's to say, as for the GPR sources.
    put(u, c.dec_ooe, "pred_reg", pidx);
    q_.push_back({u, m.tid});
  }

  bool busy() const override { return !q_.empty(); }
};

// ---- FET: trace-driven fetch -------------------------------------------------------
//
// The ORDER of fetch comes from the oracle (no branch unit yet: a taken
// branch would simply be the next record's pc). The BYTES do not: they are
// read out of lines fetched through ITLB and the ifill path.

class Fet : public Stub {
public:
  Fet(int inst, Kernel &k) : Stub(inst, k), ids_(ch().fet_mlc) {}
  const char *kind() const override { return "fet"; }

private:
  static constexpr unsigned kPage = 4096;
  bool launched_ = false;
  size_t next_ = 0;
  std::map<uint64_t, uint64_t> page_;       ///< virtual page -> physical page
  std::set<uint64_t> itlb_wait_;
  std::map<uint64_t, Line> line_;           ///< by virtual line address
  IdPool ids_;
  std::map<unsigned, uint64_t> ifill_wait_; ///< virtual line, by req_id
  std::deque<Q> fills_, itlbs_;

  void work() override {
    const Ch &c = ch();
    const auto &recs = k_.orc.recs;
    if (has(c.rau_fet, 0)) {
      Receiver::Msg m = take(c.rau_fet, 0);
      const uint64_t start = get(m.payload, c.rau_fet, "start_pc");
      if (recs.empty() || start != recs[0].pc)
        k_.fail("fet: launch at %llx, but ccv-sim began elsewhere",
                (unsigned long long)start);
      launched_ = true;
    }
    if (has(c.miu_fet, 0)) {
      Receiver::Msg m = take(c.miu_fet, 0);
      if (itlb_wait_.empty()) { k_.fail("fet: an ITLB refill it did not ask for"); }
      else {
        page_[*itlb_wait_.begin()] = get(m.payload, c.miu_fet, "itlb_refill");
        itlb_wait_.erase(itlb_wait_.begin());
      }
    }
    if (has(c.mlc_fet, 0)) {
      Receiver::Msg m = take(c.mlc_fet, 0);
      const unsigned id = unsigned(get(m.payload, c.mlc_fet, "req_id"));
      auto w = ifill_wait_.find(id);
      if (w == ifill_wait_.end()) {
        k_.fail("fet: a fill for req_id %u, which is not outstanding", id);
      } else {
        const uint64_t vl = w->second;
        line_[vl] = getLine(m.payload, field(c.mlc_fet, "line_data").lsb);
        ifill_wait_.erase(w);
        ids_.release(id);
        emit(now_, m.tid, EV_MEM_RSP, UNIT_FET, uint32_t(vl), uint32_t(vl >> 32), 2);
      }
    }
    // Warp 0 is tier-1 stream 0: binding group 0, slots 0 and 1, in order.
    for (unsigned s = 0; s != 2 && launched_ && next_ != recs.size(); ++s) {
      const Record &r = recs[next_];
      bool ready = true;
      for (uint64_t a = r.pc / kLine * kLine; a < r.pc + r.size; a += kLine)
        if (!line_.count(a)) { ready = false; want(a); }
      if (!ready || !can(c.fet_dec, s)) break;
      uint64_t word = 0;
      for (unsigned b = 0; b != r.size; ++b) {
        const uint64_t a = r.pc + b;
        word |= uint64_t(line_[a / kLine * kLine][a % kLine]) << (8 * b);
      }
      if (k_.brk == "corrupt-fetch" && r.seq == 5) word ^= 0x100;
      Bits f = msgOf(c.fet_dec);
      put(f, c.fet_dec, "warp_id", 0);
      put(f, c.fet_dec, "pc", r.pc);
      put(f, c.fet_dec, "instr", word);
      put(f, c.fet_dec, "length", r.size / 2 - 1);
      send(c.fet_dec, s, f, instrUid(r.seq));
      ++next_;
    }
    if (!itlbs_.empty() && can(c.fet_miu, 0)) {
      send(c.fet_miu, 0, itlbs_.front().msg, itlbs_.front().tid);
      itlbs_.pop_front();
    }
    if (!fills_.empty() && can(c.fet_mlc, 0)) {
      send(c.fet_mlc, 0, fills_.front().msg, fills_.front().tid);
      fills_.pop_front();
    }
  }

  /// Ask for a line: translate its page first, then fill it. Each once.
  void want(uint64_t vline) {
    const Ch &c = ch();
    const uint64_t vp = vline / kPage;
    for (auto &w : ifill_wait_) if (w.second == vline) return;
    auto p = page_.find(vp);
    if (p == page_.end()) {
      if (itlb_wait_.count(vp)) return;
      Bits r = msgOf(c.fet_miu);
      put(r, c.fet_miu, "virtual_page", vp);
      itlbs_.push_back({0, r, makeUid(IdClass::kTxn, g_unowned_txn++)});
      itlb_wait_.insert(vp);
      return;
    }
    if (!ids_.any()) return;                 // all fills in flight: wait
    Bits r = msgOf(c.fet_mlc);
    const unsigned id = ids_.take();
    put(r, c.fet_mlc, "req_id", id);
    const uint64_t pa = p->second * kPage + vline % kPage;
    put(r, c.fet_mlc, "phys_addr", pa);
    const uint64_t tid = makeUid(IdClass::kTxn, g_unowned_txn++);
    fills_.push_back({0, r, tid});
    ifill_wait_[id] = vline;
    emit(now_, tid, EV_MEM_REQ, UNIT_FET, uint32_t(pa), uint32_t(pa >> 32), 2);
  }

  bool busy() const override {
    return (launched_ && next_ != k_.orc.recs.size()) || !itlb_wait_.empty() ||
           !ifill_wait_.empty() || !fills_.empty() || !itlbs_.empty();
  }
};

// ---- RAU: launches the one warp -------------------------------------------------------

class Rau : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "rau"; }

private:
  bool launch_ = false, alloc_ = false, cta_ = false;

  void work() override {
    const Ch &c = ch();
    const uint64_t none = makeUid(IdClass::kNone, 0);
    if (!alloc_ && can(c.rau_ooe, 0)) {
      Bits a = msgOf(c.rau_ooe);
      put(a, c.rau_ooe, "warp_id", 0);
      put(a, c.rau_ooe, "prf_base", 0);
      put(a, c.rau_ooe, "prf_size", kArchGprs);
      put(a, c.rau_ooe, "activate_or_free", 1);
      send(c.rau_ooe, 0, a, none);
      alloc_ = true;
    }
    if (!cta_ && can(c.rau_miu, 0)) {
      Bits a = msgOf(c.rau_miu);
      put(a, c.rau_miu, "cta_slot", 0);
      send(c.rau_miu, 0, a, none);
      cta_ = true;
    }
    // Launch last, a cycle after the allocation, so the warp's registers
    // exist before its first instruction can reach them.
    if (alloc_ && cta_ && !launch_ && can(c.rau_fet, 0)) {
      Bits l = msgOf(c.rau_fet);
      put(l, c.rau_fet, "warp_id", 0);
      put(l, c.rau_fet, "start_pc", k_.orc.code_base);
      // code_bounds: [63:0] base, [103:64] length (placeholder split).
      const FieldDesc &cb = field(c.rau_fet, "code_bounds");
      l.set(cb.lsb, 64, k_.orc.code_base);
      l.set(cb.lsb + 64, cb.width - 64, k_.orc.code.size());
      send(c.rau_fet, 0, l, none);
      launch_ = true;
    }
  }
  bool busy() const override { return !launch_; }
};

/// SPM, SYU, PCA, CRU: nothing on vadd's path.
class Idle : public Stub {
public:
  Idle(int inst, Kernel &k, const char *n) : Stub(inst, k), n_(n) {}
  const char *kind() const override { return n_; }
private:
  void work() override {}
  const char *n_;
};

} // namespace

std::unique_ptr<Block> makeKernelBlock(int inst, Kernel &k) {
  if (inst < 0) return std::make_unique<Testbench>(inst, k);
  switch (kBlkInsts[inst].type) {
  case Blk::FET:  return std::make_unique<Fet>(inst, k);
  case Blk::DEC:  return std::make_unique<Dec>(inst, k);
  case Blk::OOE:  return std::make_unique<Ooe>(inst, k);
  case Blk::RCU:  return std::make_unique<Rcu>(inst, k);
  case Blk::LANE: return std::make_unique<Lane>(inst, k);
  case Blk::MIU:  return std::make_unique<Miu>(inst, k);
  case Blk::DCU:  return std::make_unique<Dcu>(inst, k);
  case Blk::MLC:  return std::make_unique<Mlc>(inst, k);
  case Blk::EXB:  return std::make_unique<Exb>(inst, k);
  case Blk::RAU:  return std::make_unique<Rau>(inst, k);
  default:
    return std::make_unique<Idle>(inst, k, blkName(kBlkInsts[inst].type));
  }
}

KernelReport compareFinal(Kernel &k) {
  KernelReport r;
  const Oracle &o = k.orc;
  for (unsigned a = 0; a != kArchGprs; ++a)
    for (unsigned l = 0; l != kLanes; ++l)
      if (k.gpr[k.prf_base + a][l] != o.final_gpr[a][l]) {
        if (r.gpr_mismatch++ < 4)
          std::fprintf(stderr, "FINAL R%u lane %u: machine %08x, ccv-sim %08x\n",
                       a, l, k.gpr[k.prf_base + a][l], o.final_gpr[a][l]);
      }
  for (unsigned p = 0; p != kArchPreds; ++p)
    if (k.pred[physPred(0, p)] != o.final_pred[p]) {
      ++r.pred_mismatch;
      std::fprintf(stderr, "FINAL P%u: machine %08x, ccv-sim %08x\n", p,
                   k.pred[physPred(0, p)], o.final_pred[p]);
    }
  for (auto &w : o.final_mem) {
    uint32_t v = 0;
    for (unsigned b = 0; b != 4; ++b) {
      auto it = k.mem.find(w.first + b);
      v |= uint32_t(it == k.mem.end() ? 0 : it->second) << (8 * b);
    }
    if (v != w.second && r.mem_mismatch++ < 4)
      std::fprintf(stderr, "FINAL [%llx]: machine %08x, ccv-sim %08x\n",
                   (unsigned long long)w.first, v, w.second);
  }
  r.order_ok = k.retired == o.issue_groups;
  for (size_t i = 0; i != k.retire_order.size(); ++i)
    r.order_ok = r.order_ok && k.retire_order[i] == i;
  for (unsigned c = 0; c != kNumChans; ++c) {
    if (k.rx_per_chan[c]) ++r.channels_used;
    else r.unused += std::string(r.unused.empty() ? "" : " ") + kChans[c].name;
  }
  return r;
}

} // namespace skel
} // namespace ccv
