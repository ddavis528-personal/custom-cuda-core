//===-- portdump.cpp - one block's ports as a VCD (RA-34) ---------------===//
#include "portdump.h"

#include "ccv_params.h"

#include <cstring>

namespace ccv {
namespace skel {

namespace {

/// The SV top's instance name for a block instance: the rule
/// tools/gen-top.py applies, as ccv-skel --dump-wiring restates it.
std::string instName(unsigned idx) {
  const BlkInst &b = kBlkInsts[idx];
  unsigned same = 0;
  for (const BlkInst &o : kBlkInsts) same += o.type == b.type;
  char buf[64];
  if (same == 1) std::snprintf(buf, sizeof buf, "u_%s", blkName(b.type));
  else std::snprintf(buf, sizeof buf, "u_%s_%02u", blkName(b.type), b.index);
  return buf;
}

unsigned typeCount(Blk t) {
  unsigned n = 0;
  for (const BlkInst &o : kBlkInsts) n += o.type == t;
  return n;
}

std::string bin(uint64_t v, uint32_t w) {
  std::string s(w, '0');
  for (uint32_t i = 0; i != w; ++i)
    if ((v >> i) & 1) s[w - 1 - i] = '1';
  return s;
}

std::string bin(const Bits &b) {
  std::string s(b.size(), '0');
  for (uint32_t i = 0; i != b.size(); ++i)
    if (b.bit(i)) s[b.size() - 1 - i] = '1';
  return s;
}

std::string vcdId(size_t n) {
  std::string s;
  do { s += char('!' + n % 94); n /= 94; } while (n);
  return s;
}

} // namespace

std::string PortDump::open(const std::string &spec, const std::string &comment) {
  const size_t eq = spec.find('=');
  if (eq == std::string::npos || eq == 0 || eq + 1 == spec.size())
    return "--port-dump takes INST=FILE (e.g. rcu=build/rcu.vcd)";
  std::string want = spec.substr(0, eq);
  if (want.rfind("u_", 0) != 0) want = "u_" + want;
  for (unsigned b = 0; b != kNumBlkInsts; ++b)
    if (instName(b) == want) inst_ = int(b);
  if (inst_ < 0) return "--port-dump: no block instance " + want;
  const Blk type = kBlkInsts[inst_].type;
  for (const FabDesc &fd : kFabs) {
    bool member = false;
    for (unsigned i = 0; i != fd.nblks; ++i) member |= fd.blks[i] == type;
    if ((member || fd.end == type) && typeCount(type) > 1)
      return "--port-dump: " + want + " shares fabric " + fd.name +
             " with its siblings, which the skeleton keeps one copy of";
  }
  const std::string path = spec.substr(eq + 1);
  f_ = std::fopen(path.c_str(), "w");
  if (!f_) return "--port-dump: cannot write " + path;
  scope_ = want;
  comment_ = comment;
  build();
  return "";
}

void PortDump::build() {
  const Blk type = kBlkInsts[inst_].type;
  auto add = [&](std::string name, uint32_t w, Src src) -> Var & {
    vars_.push_back(Var{std::move(name), vcdId(vars_.size()), w, src});
    return vars_.back();
  };
  add("rst_n", 1, kRst);
  for (const FabDesc &fd : kFabs) {
    unsigned at = ~0u;
    for (unsigned i = 0; i != fd.nblks; ++i)
      if (fd.blks[i] == type) at = i;
    if (fd.kind == FabKind::BROADCAST) {
      if (fd.end == type || at != ~0u) add(fd.name, fd.width, kFab).slot = fd.slot_base;
    } else if (fd.end == type) {
      Var &v = add(fd.port, fd.width * fd.nblks, kGather);
      v.slot = fd.slot_base;
      v.n = fd.nblks;
    } else if (at != ~0u) {
      add(fd.name, fd.width, kFab).slot = fd.slot_base + at;
    }
  }
  const bool one_of_many = typeCount(type) > 1;
  for (const ChanInst &ci : kChanInsts)
    for (bool at_src : {true, false}) {
      if ((at_src ? ci.src : ci.dst) != inst_) continue;
      const ChanDesc &cd = kChans[ci.chan];
      std::string base = cd.name + 4;   // ccv_ dropped, as gen-top does
      if (!one_of_many && cd.ninst > 1) {
        char c[8];
        std::snprintf(c, sizeof c, "_c%02u", ci.inst);
        base += c;
      }
      std::vector<size_t> valids;
      for (unsigned s = 0; s != cd.rate; ++s) {
        std::string pre = base;
        if (cd.rate > 1) pre += "_s" + std::to_string(s);
        const unsigned k = ci.slot_base + s;
        const bool shift = at_src && ci.bnd_src;
        valids.push_back(vars_.size());
        Var &v = add(pre + "_valid", 1, kFwdValid);
        v.slot = k; v.at_src = at_src; v.shift = shift;
        Var &p = add(pre + "_payload", cd.bits, kFwdPayload);
        p.slot = k; p.at_src = at_src; p.shift = shift;
        // A credit-on-receipt end's block has no credit port: the wrapper
        // returns it (params/links.json; AR's rev 322).
        if (at_src || !ci.cor) {
          Var &c = add(pre + "_credit", 1, kBack);
          c.slot = k; c.at_src = at_src; c.credit = true;
        }
        Var &st = add(pre + "_stall", 1, kBack);
        st.slot = k; st.at_src = at_src;
      }
      Var &w = add(base + "_wake", 1, kWake);
      w.slots.assign(valids.begin(), valids.end());   // var indices of the valids
    }

  std::fprintf(f_, "$comment\n  ccv-skel port dump (RA-34): %s, CCV_P_PHYS_REGS=%u, "
               "CCV_WAKE_LAT=%u; wake derived, CSR ports not modelled.%s%s\n$end\n",
               scope_.c_str(), unsigned(ccv::prov::kPhysRegs), unsigned(ccv::kWakeLat),
               comment_.empty() ? "" : " ", comment_.c_str());
  std::fprintf(f_, "$timescale 1ns $end\n$scope module %s $end\n", scope_.c_str());
  std::fprintf(f_, "$var wire 1 %s core_clk $end\n", vcdId(vars_.size()).c_str());
  for (const Var &v : vars_)
    std::fprintf(f_, "$var wire %u %s %s%s $end\n", v.width, v.id.c_str(), v.name.c_str(),
                 v.width > 1 ? (" [" + std::to_string(v.width - 1) + ":0]").c_str() : "");
  std::fprintf(f_, "$upscope $end\n$enddefinitions $end\n");
  last_.assign(vars_.size(), "");
}

PortDump::Sample PortDump::take(Machine &m, bool in_reset) const {
  Sample out(vars_.size());
  auto &slots = m.slots();
  const auto &fab = m.fabCur();
  for (size_t i = 0; i != vars_.size(); ++i) {
    const Var &v = vars_[i];
    switch (v.src) {
    case kRst: out[i] = in_reset ? "0" : "1"; break;
    case kFab: out[i] = bin(fab[v.slot], v.width); break;
    case kGather: {
      std::string s;
      const uint32_t w = v.width / v.n;
      for (unsigned j = v.n; j-- != 0;) s += bin(fab[v.slot + j], w);   // source 0 lowest
      out[i] = s;
      break;
    }
    case kFwdValid:
    case kFwdPayload: {
      Slot &sl = slots[v.slot];
      const SlotSignals &e = v.at_src ? sl.src().cur : sl.dst().cur;
      out[i] = v.src == kFwdValid ? (e.valid ? "1" : "0") : bin(e.payload);
      break;
    }
    case kBack: {
      Slot &sl = slots[v.slot];
      const SlotSignals &e = v.at_src ? sl.src().cur : sl.dst().cur;
      out[i] = (v.credit ? e.credit : e.stall) ? "1" : "0";
      break;
    }
    case kWake: break;   // from the lookahead, at emit
    }
  }
  return out;
}

void PortDump::sample(Machine &m, bool in_reset) {
  if (!f_) return;
  la_.push_back(take(m, in_reset));
  // A wake looks CCV_WAKE_LAT cycles ahead of the valid it is for, and that
  // valid may itself be a flopped sending end's, one more ahead.
  if (la_.size() > ccv::kWakeLat + 1) {
    emit(0);
    la_.pop_front();
  }
}

/// Writes la_[i]'s cycle (i is always 0: the oldest sample held).
void PortDump::emit(size_t i) {
  auto raw = [&](size_t k, size_t v) -> const std::string * {
    return k < la_.size() ? &la_[k][v] : nullptr;
  };
  // A port's value at lookahead k: a flopped sending end shows the next
  // sample's register (held at the run's end).
  auto port = [&](size_t k, size_t v) -> const std::string * {
    if (vars_[v].shift) {
      if (const std::string *n = raw(k + 1, v)) return n;
    }
    return raw(k, v);
  };
  std::fprintf(f_, "#%llu\n0%s\n", (unsigned long long)(t_ * 10),
               vcdId(vars_.size()).c_str());
  for (size_t v = 0; v != vars_.size(); ++v) {
    std::string val;
    if (vars_[v].src == kWake) {
      bool any = false;
      for (unsigned j : vars_[v].slots) {
        const std::string *x = port(i + ccv::kWakeLat, j);
        any |= x && *x == "1";
      }
      val = any ? "1" : "0";
    } else {
      val = *port(i, v);
    }
    if (val == last_[v]) continue;
    last_[v] = val;
    if (vars_[v].width == 1) std::fprintf(f_, "%s%s\n", val.c_str(), vars_[v].id.c_str());
    else std::fprintf(f_, "b%s %s\n", val.c_str(), vars_[v].id.c_str());
  }
  std::fprintf(f_, "#%llu\n1%s\n", (unsigned long long)(t_ * 10 + 5),
               vcdId(vars_.size()).c_str());
  ++t_;
}

void PortDump::close() {
  if (!f_) return;
  while (!la_.empty()) {
    emit(0);
    la_.pop_front();
  }
  std::fprintf(f_, "#%llu\n", (unsigned long long)(t_ * 10));
  std::fclose(f_);
  f_ = nullptr;
}

} // namespace skel
} // namespace ccv
