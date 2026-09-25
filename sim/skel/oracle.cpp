//===-- oracle.cpp - read ccv-sim -oracle records -----------------------===//
//
// A JSON reader just big enough for the record format: objects, arrays,
// strings without escapes, and non-negative integers. Anything else is a
// format error, reported with the line it was on -- the records are generated,
// so an unexpected shape means the generator changed, and guessing past it
// would feed the skeleton a wrong oracle.
//===----------------------------------------------------------------------===//
#include "oracle.h"

#include <cstdio>
#include <fstream>
#include <map>

namespace ccv {
namespace skel {

namespace {

struct JV {
  enum Kind { kNum, kStr, kArr, kObj } kind = kNum;
  uint64_t num = 0;
  bool neg = false;       ///< immediates are signed; everything else is not
  std::string str;
  std::vector<JV> arr;
  std::map<std::string, JV> obj;

  const JV &at(const std::string &k) const {
    auto it = obj.find(k);
    if (it == obj.end()) throw std::string("missing key \"" + k + "\"");
    return it->second;
  }
  bool has(const std::string &k) const { return obj.count(k) != 0; }
  uint64_t u() const {
    if (kind != kNum || neg) throw std::string("expected a non-negative number");
    return num;
  }
  int64_t i() const {
    if (kind != kNum) throw std::string("expected a number");
    return neg ? -int64_t(num) : int64_t(num);
  }
  const std::string &s() const {
    if (kind != kStr) throw std::string("expected a string");
    return str;
  }
  const std::vector<JV> &a() const {
    if (kind != kArr) throw std::string("expected an array");
    return arr;
  }
};

class Parser {
public:
  explicit Parser(const std::string &t) : t_(t) {}
  JV parse() {
    JV v = value();
    ws();
    if (i_ != t_.size()) throw std::string("trailing characters");
    return v;
  }

private:
  void ws() { while (i_ < t_.size() && (t_[i_] == ' ' || t_[i_] == '\t')) ++i_; }
  char peek() { ws(); return i_ < t_.size() ? t_[i_] : '\0'; }
  void expect(char c) {
    if (peek() != c) throw std::string("expected '") + c + "'";
    ++i_;
  }
  JV value() {
    const char c = peek();
    JV v;
    if (c == '{') {
      v.kind = JV::kObj;
      ++i_;
      if (peek() == '}') { ++i_; return v; }
      for (;;) {
        JV k = value();
        expect(':');
        v.obj[k.s()] = value();
        if (peek() == ',') { ++i_; continue; }
        expect('}');
        return v;
      }
    }
    if (c == '[') {
      v.kind = JV::kArr;
      ++i_;
      if (peek() == ']') { ++i_; return v; }
      for (;;) {
        v.arr.push_back(value());
        if (peek() == ',') { ++i_; continue; }
        expect(']');
        return v;
      }
    }
    if (c == '"') {
      v.kind = JV::kStr;
      ++i_;
      while (i_ < t_.size() && t_[i_] != '"') {
        if (t_[i_] == '\\') throw std::string("escapes are not part of the format");
        v.str += t_[i_++];
      }
      expect('"');
      return v;
    }
    if (c == '-' || (c >= '0' && c <= '9')) {
      if (c == '-') { v.neg = true; ++i_; }
      if (i_ == t_.size() || t_[i_] < '0' || t_[i_] > '9')
        throw std::string("a sign with no digits");
      while (i_ < t_.size() && t_[i_] >= '0' && t_[i_] <= '9')
        v.num = v.num * 10 + uint64_t(t_[i_++] - '0');
      return v;
    }
    throw std::string("unexpected character '") + c + "'";
  }

  const std::string &t_;
  size_t i_ = 0;
};

std::vector<uint8_t> hexBytes(const std::string &h) {
  if (h.size() % 2) throw std::string("odd-length hex string");
  std::vector<uint8_t> b;
  for (size_t k = 0; k != h.size(); k += 2)
    b.push_back(uint8_t(std::stoul(h.substr(k, 2), nullptr, 16)));
  return b;
}

RegVal regVal(const JV &j) {
  RegVal r;
  const std::string &n = j.at("reg").s();
  if (n.size() < 2 || (n[0] != 'R' && n[0] != 'P'))
    throw std::string("register \"" + n + "\" is neither R<n> nor P<n>");
  r.pred = n[0] == 'P';
  r.idx = unsigned(std::stoul(n.substr(1)));
  if (r.idx >= (r.pred ? kArchPreds : kArchGprs))
    throw std::string("register \"" + n + "\" out of range");
  const JV &v = j.at("vals");
  if (r.pred) {
    r.p = uint32_t(v.u());
  } else {
    if (v.a().size() != kLanes) throw std::string("GPR value is not 32 lanes");
    for (unsigned l = 0; l != kLanes; ++l) r.v[l] = uint32_t(v.a()[l].u());
  }
  return r;
}

std::vector<std::pair<uint64_t, uint32_t>> words(const JV &j) {
  std::vector<std::pair<uint64_t, uint32_t>> w;
  for (const JV &p : j.a()) {
    if (p.a().size() != 2) throw std::string("memory entry is not [addr, value]");
    w.push_back({p.a()[0].u(), uint32_t(p.a()[1].u())});
  }
  return w;
}

} // namespace

std::vector<const RegVal *> Record::gprUses() const {
  std::vector<const RegVal *> g;
  for (const RegVal &r : uses) if (!r.pred) g.push_back(&r);
  return g;
}
const RegVal *Record::predUse() const {
  for (const RegVal &r : uses) if (r.pred) return &r;
  return nullptr;
}
const RegVal *Record::gprDef() const {
  for (const RegVal &r : defs) if (!r.pred) return &r;
  return nullptr;
}
const RegVal *Record::predDef() const {
  for (const RegVal &r : defs) if (r.pred) return &r;
  return nullptr;
}

std::string Oracle::load(const std::string &path) {
  std::ifstream in(path);
  if (!in) return "cannot open " + path;
  std::string line;
  unsigned n = 0;
  bool have_init = false, have_final = false;
  try {
    while (std::getline(in, line)) {
      ++n;
      if (line.empty()) continue;
      JV j = Parser(line).parse();
      if (j.has("init")) {
        const JV &i = j.at("init");
        code_base = i.at("code_base").u();
        threads = unsigned(i.at("threads").u());
        ctaid = unsigned(i.at("ctaid").u());
        code = hexBytes(i.at("code").s());
        init_mem = words(i.at("mem"));
        have_init = true;
      } else if (j.has("final")) {
        const JV &f = j.at("final");
        const auto &g = f.at("gpr").a();
        if (g.size() != kArchGprs) throw std::string("final gpr is not 16 registers");
        for (unsigned r = 0; r != kArchGprs; ++r) {
          if (g[r].a().size() != kLanes) throw std::string("final gpr row is not 32 lanes");
          for (unsigned l = 0; l != kLanes; ++l)
            final_gpr[r][l] = uint32_t(g[r].a()[l].u());
        }
        const auto &p = f.at("pred").a();
        if (p.size() != kArchPreds) throw std::string("final pred is not 4 registers");
        for (unsigned r = 0; r != kArchPreds; ++r) final_pred[r] = uint32_t(p[r].u());
        final_mem = words(f.at("mem"));
        issue_groups = unsigned(f.at("issue_groups").u());
        have_final = true;
      } else {
        Record r;
        r.seq = j.at("seq").u();
        if (r.seq != recs.size()) throw std::string("records out of sequence");
        r.pc = j.at("pc").u();
        r.size = unsigned(j.at("size").u());
        r.bytes = hexBytes(j.at("bytes").s());
        if (r.bytes.size() != r.size) throw std::string("bytes disagree with size");
        r.mask = uint32_t(j.at("mask").u());
        r.op = j.at("op").s();
        r.kind = j.at("kind").s();
        r.load = j.at("load").u() != 0;
        r.store = j.at("store").u() != 0;
        for (const JV &m : j.at("imms").a()) r.imms.push_back(m.i());
        for (const JV &u : j.at("uses").a()) r.uses.push_back(regVal(u));
        for (const JV &d : j.at("defs").a()) r.defs.push_back(regVal(d));
        for (const JV &m : j.at("mem").a()) {
          MemAcc a;
          a.lane = unsigned(m.at("lane").u());
          a.shared = m.at("space").s() == "shared";
          a.write = m.at("w").u() != 0;
          a.addr = m.at("addr").u();
          a.bytes = unsigned(m.at("bytes").u());
          a.val = uint32_t(m.at("val").u());
          r.mem.push_back(a);
        }
        recs.push_back(std::move(r));
      }
    }
  } catch (const std::string &e) {
    return path + ":" + std::to_string(n) + ": " + e;
  } catch (const std::exception &e) {
    return path + ":" + std::to_string(n) + ": " + e.what();
  }
  if (!have_init || !have_final) return path + ": missing init or final record";
  if (issue_groups != recs.size())
    return path + ": final record counts " + std::to_string(issue_groups) +
           " issue groups but the file holds " + std::to_string(recs.size());
  return "";
}

} // namespace skel
} // namespace ccv
