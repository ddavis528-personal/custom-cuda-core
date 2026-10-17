#!/usr/bin/env bash
# Yosys, strict (OI-44): the warnings that mean the netlist is not the RTL
# fail the run, wherever the gate runs Yosys.
#
# tools/shim/yosys passes each such warning to yosys -e; tools/verify.sh puts
# tools/shim first on PATH. What must hold:
#
#   the gate's yosys   is the shim, and SymbiYosys reaches Yosys through it
#   each pattern       has a fixture, test/yosys/ys_*.sv, naming it on its
#                      "Provokes:" line; plain Yosys synthesises the fixture
#                      with that warning and exit 0, the shim refuses it
#   clean RTL          test/yosys/ys_clean.sv passes the shim
#
#   tools/check-yosys-strict.sh          standalone: puts the shim on PATH itself
#   tools/check-yosys-strict.sh --gate   from tools/verify.sh, whose PATH must
#                                        already have it first
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
B="$R/build/yosys-strict"
rm -rf "$B" && mkdir -p "$B"
fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

SHIM="$R/tools/shim/yosys"
incoming=$(command -v yosys || true)
case ":$PATH:" in *":$R/tools/shim:"*) ;; *) export PATH="$R/tools/shim:$PATH" ;; esac
# The Yosys the shim wraps: the first on PATH that is not the shim.
REAL=""
IFS=: read -ra dirs <<< "$PATH"
for d in "${dirs[@]}"; do
  [ -n "$d" ] && [ -d "$d" ] || continue
  [ "$(cd "$d" && pwd -P)" = "$R/tools/shim" ] && continue
  if [ -x "$d/yosys" ]; then REAL="$d/yosys"; break; fi
done
if [ -z "$REAL" ]; then
  say "strict Yosys" "SKIP -- yosys not installed"
  exit 0
fi

# -- the gate's yosys ---------------------------------------------------------
if [ "$(command -v yosys)" = "$SHIM" ]; then
  say "yosys on PATH is tools/shim/yosys" "PASS"
else
  bad "yosys on PATH is tools/shim/yosys" "$(command -v yosys)"
fi
if [ "${1:-}" = --gate ]; then
  if [ "$incoming" = "$SHIM" ]; then
    say "tools/verify.sh runs every check with the shim" "PASS"
  else
    bad "tools/verify.sh runs every check with the shim" "its yosys is ${incoming:-none}"
  fi
fi

synth() {  # synth <yosys> <fixture> -> output in $B/<name>.<tag>.log, rc
  local y="$1" f="$2" tag="$3" m
  m=$(basename "$f" .sv)
  "$y" -q -p "read_verilog -sv $f; synth -top $m" >"$B/$m.$tag.log" 2>&1
}

# -- every pattern has a fixture; plain warns, strict refuses ----------------
mapfile -t PATS < <(sed -n "/^STRICT=(/,/^)/p" "$SHIM" | sed -n "s/^ *'\([^']*\)'.*/\1/p")
if [ ${#PATS[@]} -eq 0 ]; then
  bad "the shim's patterns" "none read from $SHIM"
fi
for p in "${PATS[@]}"; do
  fx=$(grep -l "^// Provokes: $p\$" test/yosys/ys_*.sv | head -1)
  if [ -z "$fx" ]; then
    bad "'$p'" "no fixture in test/yosys/ provokes it"
    continue
  fi
  m=$(basename "$fx" .sv)
  if ! synth "$REAL" "$fx" plain; then
    bad "$m: plain Yosys passes it" "exit $?, see $B/$m.plain.log"
    continue
  fi
  if ! grep -q "Warning: .*$p" "$B/$m.plain.log"; then
    bad "$m: plain Yosys warns '$p'" "no such warning, see $B/$m.plain.log"
    continue
  fi
  if synth yosys "$fx" strict; then
    bad "$m: the shim refuses '$p'" "it passed"
  elif grep -q "ERROR: .*$p" "$B/$m.strict.log"; then
    say "$m: '$p'" "refused (plain Yosys: a warning)"
  else
    bad "$m: the shim refuses '$p'" "failed otherwise: $(grep -m1 ERROR "$B/$m.strict.log")"
  fi
done
for fx in test/yosys/ys_*.sv; do
  p=$(sed -n 's|^// Provokes: ||p' "$fx")
  [ -z "$p" ] && continue
  printf '%s\n' "${PATS[@]}" | grep -qxF "$p" ||
    bad "$(basename "$fx")" "provokes '$p', which the shim does not list"
done

# -- clean RTL passes ---------------------------------------------------------
if synth yosys test/yosys/ys_clean.sv strict; then
  say "ys_clean: the shim passes clean RTL" "PASS"
else
  bad "ys_clean: the shim passes clean RTL" "$(grep -m1 ERROR "$B/ys_clean.strict.log")"
fi

# -- SymbiYosys reaches Yosys through the shim --------------------------------
# One trivial proof over the out-of-bounds fixture: plain, it passes; with
# the shim first on PATH, Yosys inside sby refuses it.
if command -v sby >/dev/null 2>&1; then
  mkdir -p "$B/sby"
  cat > "$B/sby/s.sv" <<'SV'
module s (input logic clk, input logic [3:0] a);
  logic [1:0] y;
  assign y = a[4:3];
  always @(posedge clk) assert (y[0] == a[3]);
endmodule
SV
  cat > "$B/sby/s.sby" <<'SBY'
[options]
mode bmc
depth 2

[engines]
smtbmc cvc5

[script]
read -formal s.sv
prep -top s

[files]
s.sv
SBY
  plain_path=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vx "$R/tools/shim" | paste -sd:)
  if (cd "$B/sby" && PATH="$plain_path" sby -f -d plain s.sby >/dev/null 2>&1); then
    if (cd "$B/sby" && sby -f -d strict s.sby >"$B/sby/strict.log" 2>&1); then
      bad "sby: Yosys inside it is the shim" "the out-of-bounds select passed"
    elif grep -q "select out of bounds" "$B/sby/strict.log"; then
      say "sby: Yosys inside it is the shim" "PASS"
    else
      bad "sby: Yosys inside it is the shim" "failed otherwise, see $B/sby/strict.log"
    fi
  else
    bad "sby: the plain proof passes" "see $B/sby/plain/logfile.txt"
  fi
else
  say "sby" "SKIP -- not installed"
fi

exit $fail
