#!/usr/bin/env bash
# Materialize the pinned compiler snapshot (tools/compiler.lock) and print its
# directory. Cached under build/compiler/<commit>/, so a gate run fetches at
# most once per pin.
#
#   tools/fetch-compiler.sh           print the snapshot's directory
#   tools/fetch-compiler.sh --bump    re-pin to the compiler's `release` tip
#
# A snapshot is only used after it proves itself: its SNAPSHOT.md must name
# the source commit the lock records, the built ccv-sim must match the sha256
# in that snapshot's own manifest, and it must run here. A fetch that fails
# FAILS -- the kernels' oracles have no other source, and a check that could
# not run has not passed.
set -uo pipefail
cd "$(dirname "$0")/.."
LOCK=tools/compiler.lock
die() { echo "fetch-compiler: $*" >&2; exit 1; }
get() { sed -n "s/^$1=//p" "$LOCK"; }
REPO=$(get repo); COMMIT=$(get commit); SOURCE=$(get source)
[ -n "$REPO" ] && [ -n "$COMMIT" ] || die "$LOCK is missing repo= or commit="

CACHE=build/compiler.git
[ -d "$CACHE" ] || git init -q --bare "$CACHE" || die "cannot create $CACHE"

if [ "${1:-}" = "--bump" ]; then
  tip=$(git ls-remote "$REPO" refs/heads/release | cut -f1)
  [ -n "$tip" ] || die "no release branch at $REPO"
  git -C "$CACHE" fetch -q --depth=1 "$REPO" "$tip" || die "fetch of $tip failed"
  src=$(git -C "$CACHE" show "$tip:SNAPSHOT.md" |
        sed -n 's/^| Source | .* @ `\([0-9a-f]*\)` |$/\1/p')
  [ -n "$src" ] || die "the snapshot at $tip names no source commit"
  sed -i "s/^commit=.*/commit=$tip/; s/^source=.*/source=$src/" "$LOCK"
  echo "fetch-compiler: pinned $tip (source $src); review and commit $LOCK"
  exit 0
fi

DIR=build/compiler/$COMMIT
if [ ! -f "$DIR/.verified" ]; then
  rm -rf "$DIR"; mkdir -p "$DIR"
  git -C "$CACHE" cat-file -e "$COMMIT^{commit}" 2>/dev/null ||
    git -C "$CACHE" fetch -q --depth=1 "$REPO" "$COMMIT" ||
    die "cannot fetch $COMMIT from $REPO"
  git -C "$CACHE" archive "$COMMIT" | tar -x -C "$DIR" || die "extract failed"
  S="$DIR/SNAPSHOT.md"
  [ -f "$S" ] || die "$COMMIT is not a snapshot (no SNAPSHOT.md)"
  grep -q "@ \`$SOURCE\`" "$S" ||
    die "the snapshot names a different source commit than the lock's $SOURCE"
  want=$(sed -n 's/^\([0-9a-f]\{64\}\)  release\/bin\/ccv-sim$/\1/p' "$S")
  have=$(sha256sum "$DIR/release/bin/ccv-sim" | cut -d' ' -f1)
  [ -n "$want" ] && [ "$want" = "$have" ] ||
    die "release/bin/ccv-sim does not match the snapshot's manifest"
  chmod +x "$DIR/release/bin/ccv-sim"
  "$DIR/release/bin/ccv-sim" --version >/dev/null 2>&1 ||
    die "the snapshot's ccv-sim does not run here (see $DIR/release/bin/ccv-sim.txt)"
  touch "$DIR/.verified"
fi
echo "$DIR"
