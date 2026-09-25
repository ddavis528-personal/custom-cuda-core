#!/usr/bin/env bash
# Stage 1c exit criteria (§8):
#
#   "schema versioned; a stub event stream round-trips into Perfetto, AND the
#    DPI-C path emits from a trivial SystemVerilog module -- the Stage 1c
#    decision exercised, not merely decided"
#
# Both halves are checked, and the second is the one that matters: a C++-only
# emit API that turns out not to be feedable from SystemVerilog is a retrofit
# across every block built by then.
set -uo pipefail
cd "$(dirname "$0")/.."

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

# -- generated headers are current ----------------------------------------
if python3 tools/gen-event-schema.py --check >"$TMP/gen.log" 2>&1; then
  say "schema headers current and versioned" "PASS"
else
  bad "schema headers current" "$(head -1 "$TMP/gen.log")"
fi

# -- C++ emit API round-trips ---------------------------------------------
cat > "$TMP/rt.cpp" <<'CPP'
// Round-trip: write a stub stream, read it back, check every field survived.
// Checking the field VALUES rather than just the count is the point -- a
// struct-layout mistake would give the right number of records and the wrong
// contents, which is precisely the failure that makes a §5 correlation run
// lie.
#include "ccv/event.h"
#include <cstdio>
int main() {
  const char *p = "rt.ccvtrace";
  {
    ccv::EventWriter w;
    if (!w.open(p)) { std::printf("open failed\n"); return 1; }
    for (int i = 0; i < 8; ++i)
      w.emit(100 + i, 7000 + i, ccv::EV_DECODE, ccv::UNIT_FET,
             i, i * 2, i * 3);
    w.close();
  }
  ccv::EventReader r;
  if (!r.open(p)) { std::printf("reopen failed: %s\n", r.error().c_str()); return 1; }
  if (!r.schemaMatches()) { std::printf("schema mismatch\n"); return 1; }
  ccv::Event e; int n = 0;
  while (r.next(e)) {
    if (e.cycle != uint64_t(100 + n) || e.instr_uid != uint64_t(7000 + n) ||
        e.event_id != ccv::EV_DECODE || e.unit != ccv::UNIT_FET ||
        e.a != uint32_t(n) || e.b != uint32_t(n * 2) || e.c != uint32_t(n * 3)) {
      std::printf("record %d mismatched\n", n); return 1;
    }
    ++n;
  }
  if (!r.error().empty()) { std::printf("%s\n", r.error().c_str()); return 1; }
  if (n != 8) { std::printf("read %d of 8\n", n); return 1; }
  std::printf("ROUNDTRIP OK\n");
  return 0;
}
CPP
if g++ -std=c++17 -I sim/include -I sim/generated -o "$TMP/rt" \
     "$TMP/rt.cpp" sim/src/event.cpp >"$TMP/cc.log" 2>&1; then
  if (cd "$TMP" && ./rt) | grep -q "ROUNDTRIP OK"; then
    say "C++ emit API round-trips, fields intact" "PASS"
  else
    bad "C++ emit API round-trips" "$(cd "$TMP" && ./rt 2>&1 | head -1)"
  fi
else
  bad "C++ emit API compiles" "$(grep -m1 error "$TMP/cc.log")"
fi

# -- DPI-C path from SystemVerilog ----------------------------------------
# The Stage 1c decision, exercised. Verilator is the tool that has to carry
# this: it is the default simulator (§6) and the one the block-swap mechanism
# (§1) runs inside.
if command -v verilator >/dev/null 2>&1; then
  # C++ sources must be ABSOLUTE. Verilator writes the paths verbatim into the
  # generated makefile, and that makefile is run with `make -C <Mdir>`, so a
  # repo-relative path resolves against the build directory and the link fails
  # with "No rule to make target". Verilog sources are fine either way, which
  # is what makes this one easy to get wrong.
  R=$(pwd)
  if verilator --binary -j 0 --timing -Wno-fatal \
       -Irtl/include -Irtl/generated \
       -CFLAGS "-I$R/sim/include -I$R/sim/generated" \
       --top-module ccv_event_smoke --Mdir "$TMP/eobj" \
       "$R/test/smoke/ccv_event_smoke.sv" "$R/sim/src/event.cpp" \
       "$R/sim/dpi/ccv_event_dpi.cpp" \
       >"$TMP/dpi.log" 2>&1 && [ -x "$TMP/eobj/Vccv_event_smoke" ]; then
    out=$(cd "$TMP" && ./eobj/Vccv_event_smoke 2>&1)
    if echo "$out" | grep -q "CCV_EVENT_SMOKE: OK" && \
       echo "$out" | grep -q "emitted 16 events"; then
      say "DPI-C emit from SystemVerilog" "PASS"
      TRACE="$TMP/ccv_event_smoke.ccvtrace"
    else
      bad "DPI-C emit from SystemVerilog" "$(echo "$out" | head -2 | tr '\n' ' ')"
    fi
  else
    bad "DPI-C smoke builds" "$(grep -m1 '%Error' "$TMP/dpi.log" || echo '?')"
  fi
else
  say "DPI-C emit from SystemVerilog" "SKIP -- verilator not installed"
fi

# -- Perfetto round-trip ---------------------------------------------------
# Uses the trace the SystemVerilog module just wrote, not a separately
# fabricated one: that makes this a genuine end-to-end path from RTL
# instrumentation to a rendered view, which is what §1 claims to get for free.
if [ -n "${TRACE:-}" ] && [ -f "$TRACE" ]; then
  if python3 tools/trace2perfetto.py "$TRACE" -o "$TMP/t.json" \
       >"$TMP/pf.log" 2>&1; then
    if python3 - "$TMP/t.json" >/dev/null <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
ev = d["traceEvents"]
if d["ccv"]["events"] != 16:
    sys.exit("expected 16 events, got %d" % d["ccv"]["events"])
# Every Chrome trace event needs these keys or Perfetto silently drops the row.
for e in ev:
    for k in ("name", "ph", "pid"):
        if k not in e:
            sys.exit("event missing %r: %r" % (k, e))
if not any(e.get("cat") == "arbitration_sensitive" for e in ev):
    sys.exit("arbitration-sensitive events lost their category -- the §5 "
             "filter would not work")
if not any(e.get("ph") == "M" for e in ev):
    sys.exit("no track-name metadata: tracks would render as bare numbers")
print("PERFETTO OK")  # consumed by the caller, not shown
PY
    then
      say "stub stream round-trips into Perfetto JSON" "PASS"
    else
      bad "Perfetto JSON well-formed" "see above"
    fi
  else
    bad "trace2perfetto runs" "$(head -1 "$TMP/pf.log")"
  fi
else
  say "Perfetto round-trip" "SKIP -- no trace produced"
fi

exit $fail
