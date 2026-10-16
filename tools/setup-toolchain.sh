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
  iverilog \
  yosys \
  cvc5 \
  build-essential \
  cmake \
  ninja-build \
  python3 \
  git autoconf flex bison libfl2 libfl-dev zlib1g-dev help2man perl ccache

# Verilator is built from a release tag, not taken from apt: Debian's 5.020
# dates from January 2024, and a newer release is a decision (DA's response
# OI-40), so the version is pinned here and in tools/toolchain.lock.json.
# It installs under its own prefix and is linked into /usr/local/bin, which
# PATH searches before /usr/bin; Debian's package is removed so that one
# Verilator is on the machine. Building takes a while; a container that
# already has this version skips it.
# A build/ an earlier version made is cleared by the next tools/verify.sh
# (tools/build-stamp.py): make would otherwise keep its objects.
VERILATOR_TAG=v5.052
VERILATOR_PREFIX=/opt/verilator-${VERILATOR_TAG#v}
echo "== Verilator $VERILATOR_TAG =="
if ! "$VERILATOR_PREFIX/bin/verilator" --version 2>/dev/null |
     grep -q "rev $VERILATOR_TAG\$"; then
  tmp=$(mktemp -d)
  git clone --depth 1 --branch "$VERILATOR_TAG" \
    https://github.com/verilator/verilator "$tmp/verilator"
  (cd "$tmp/verilator" && autoconf && ./configure --prefix="$VERILATOR_PREFIX" &&
   make -j"$(nproc)" && $SUDO make install)
  rm -rf "$tmp"
fi
for b in "$VERILATOR_PREFIX"/bin/*; do
  $SUDO ln -sf "$b" /usr/local/bin/
done
if dpkg -s verilator >/dev/null 2>&1; then
  $SUDO apt-get remove -y verilator
fi

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
  flag=--version; [ "$t" = iverilog ] && flag=-V   # Icarus has no --version
  command -v "$t" >/dev/null 2>&1 && "$t" $flag 2>&1 | head -1 || echo "MISSING"
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
