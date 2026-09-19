#!/usr/bin/env bash
# Install the RTL toolchain this project's flow assumes (§6, §7).
#
# The container this runs in is ephemeral, so this script is the record of what
# the flow needs, not a one-time action. Everything here is free/open source;
# there is no commercial tool anywhere in the flow, by §6's design.
#
# Run it, then `tools/verify.sh` should go green.
set -euo pipefail

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

echo "== apt packages =="
$SUDO apt-get update -qq
$SUDO apt-get install -y --no-install-recommends \
  verilator \
  iverilog \
  yosys \
  cvc5 \
  build-essential \
  cmake \
  ninja-build \
  python3

# SymbiYosys is not packaged. It is the driver for §7's formal work; Yosys
# alone is the engine underneath it.
echo "== SymbiYosys =="
if ! command -v sby >/dev/null 2>&1; then
  tmp=$(mktemp -d)
  git clone --depth 1 https://github.com/YosysHQ/sby "$tmp/sby"
  (cd "$tmp/sby" && $SUDO make install PREFIX=/usr/local)
  rm -rf "$tmp"
fi

echo
echo "== versions =="
for t in verilator iverilog yosys sby cvc5; do
  printf '  %-12s ' "$t"
  command -v "$t" >/dev/null 2>&1 && "$t" --version 2>&1 | head -1 || echo "MISSING"
done

cat <<'NOTE'

Notes, all of them findings from the Stage 1a spike rather than preferences --
see docs/stage1a-findings.md:

  * cvc5 is the formal engine, and the choice is not incidental (F-7).
    Debian's boolector is from 2012 and yosys-smtbmc dies against it; the
    `abc bmc3` engine crashes on this sby/Yosys pairing's witness format.

  * Verible is NOT installed and nothing depends on it (F-5). The X-safety
    rules are relationships between constructs that stock Verible rules do not
    express, so they are enforced by tools/lint-rtl.py instead. §6's "this adds
    a fourth tool" is retracted.
NOTE
