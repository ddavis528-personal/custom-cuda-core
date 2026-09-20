#!/usr/bin/env bash
# Emit-path calibration.
#
# A test of the emit path catches a BROKEN path. The failure that matters is
# SYSTEMATIC: a DPI call a cycle off relative to the clock edge, or sampling
# before rather than after the non-blocking update. That emits a complete,
# well-formed, self-consistent stream that is uniformly wrong by one cycle --
# and at §5 correlation it does not look like an instrumentation fault, it
# looks like a consistent timing divergence in the design under test. It would
# be chased as a real finding.
#
# So this calibrates against a block whose event timing is derivable on paper:
# a three-deep fixed-latency pipeline whose correct event cycles are C+1, C+2,
# C+3 for a launch observed at cycle C. A constant offset shifts all three
# together, which is exactly the signature that would otherwise be misread.
#
# Permanent, because a change to the emit path or to the clocking convention
# can reintroduce the offset silently.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

if ! command -v verilator >/dev/null 2>&1; then
  say "emit-path calibration" "SKIP -- verilator not installed"
  exit 0
fi

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
R=$(pwd)

if ! verilator --binary -j 0 --timing -Wno-fatal -Wno-WIDTHEXPAND \
     -Irtl/include -Irtl/generated \
     -CFLAGS "-I$R/sim/include -I$R/sim/generated" \
     --top-module tb --Mdir "$TMP/obj" \
     "$R/rtl/ccv_assert_pkg.sv" "$R/test/smoke/emit_calib.sv" \
     "$R/test/smoke/tb_emit_calib.sv" \
     "$R/sim/src/event.cpp" "$R/sim/dpi/ccv_event_dpi.cpp" \
     >"$TMP/build.log" 2>&1 || [ ! -x "$TMP/obj/Vtb" ]; then
  bad "calibration fixture builds" "$(grep -m1 '%Error' "$TMP/build.log" || echo '?')"
  exit $fail
fi

out=$(cd "$TMP" && ./obj/Vtb 2>&1)
launch=$(echo "$out" | grep -oP 'CALIB launch_cycle=\K-?\d+')
if [ -z "${launch:-}" ] || [ "$launch" -lt 0 ]; then
  bad "launch observed" "testbench did not report a launch cycle"
  exit $fail
fi

if ! python3 - "$TMP/emit_calib.ccvtrace" "$launch" <<'PY'
import struct, sys
HDR = struct.Struct("<8sII16sQ")
REC = struct.Struct("<QQHHIII")
path, launch = sys.argv[1], int(sys.argv[2])
with open(path, "rb") as f:
    if len(f.read(HDR.size)) < HDR.size:
        sys.exit("trace has no header")
    recs = []
    while True:
        b = f.read(REC.size)
        if not b:
            break
        if len(b) < REC.size:
            sys.exit("truncated final record")
        recs.append(REC.unpack(b))

# Derived on paper, not read back from the instrument.
want = [(launch + 1, 1), (launch + 2, 2), (launch + 3, 3)]
got = [(r[0], r[4]) for r in recs]

if len(got) != 3:
    sys.exit("expected exactly 3 events, got %d: %r" % (len(got), got))

if got == want:
    pass
    sys.exit(0)

# A constant offset is the failure this check exists for, so it is diagnosed
# by name rather than reported as a mismatch.
offs = {g[0] - w[0] for g, w in zip(got, want)}
if len(offs) == 1 and [g[1] for g in got] == [w[1] for w in want]:
    d = offs.pop()
    sys.exit("EVERY event is offset by %+d cycles. This is an emit-path "
             "calibration error, not a design divergence -- at correlation it "
             "would read as a consistent timing difference in the DUT. "
             "expected %r, got %r" % (d, want, got))
sys.exit("event cycles do not match: expected %r, got %r" % (want, got))
PY
then
  bad "emitted cycles match the paper reference" "see above"
else
  say "emitted cycles match the paper reference" "PASS"
fi

exit $fail
