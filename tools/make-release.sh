#!/usr/bin/env bash
# A static snapshot of the repository, browsable on GitHub, WITH everything the
# build generates.
#
#   tools/make-release.sh [--branch=release] [--push]
#
# The development branch keeps generated files out of git on purpose: each has
# one source of truth in the repo, and a stale checked-in copy is a second
# truth that drifts. But some of them are the most readable form of a
# decision -- rtl/generated/ccv_interfaces.svh is where every channel's payload
# typedef lives -- and a reader on GitHub should not need a toolchain to see
# them. So a snapshot is a SEPARATE branch, never merged back:
#
#   - its tree is the source tree at one commit, exactly, plus every generated
#     file at its real path (rtl/generated/, sim/generated/), so the snapshot
#     reads and builds as the real tree does;
#   - plus curated build artifacts under release/: the gate log, each
#     kernel's run summary, its event trace and both Perfetto views, the C++
#     wiring dump. An allowlist with a size cap, not the build directory,
#     which is ~400 MB of Verilator objects;
#   - plus SNAPSHOT.md: the source commit, the date, the tool versions, the
#     gate result, and a sha256 manifest of everything under release/.
#
# Each snapshot is one commit on the release branch, whose parent is the
# previous snapshot, so the branch reads as a history of releases. It is
# tagged snapshot-<date>-<sha7>. The gate must pass: a snapshot of a red tree
# would be the one copy people read without the gate beside it.
#
# Requires a clean working tree (the snapshot must BE a commit), and makes the
# commit locally; --push publishes the branch and the tag.
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
BRANCH=release
PUSH=0
for a in "$@"; do
  case "$a" in
    --branch=*) BRANCH=${a#--branch=} ;;
    --push)     PUSH=1 ;;
    *) echo "usage: $0 [--branch=<name>] [--push]" >&2; exit 2 ;;
  esac
done
MAXFILE=$((5 * 1024 * 1024))       # no single artifact above 5 MB
MAXTOTAL=$((25 * 1024 * 1024))     # nor all of release/ above 25 MB

die() { echo "make-release: $*" >&2; exit 1; }

[ -z "$(git status --porcelain --untracked-files=no)" ] ||
  die "the working tree has uncommitted changes; a snapshot must be a commit"
SHA=$(git rev-parse HEAD)
SHA7=$(git rev-parse --short=7 HEAD)
SRCBRANCH=$(git rev-parse --abbrev-ref HEAD)
DATE=$(date -u +%Y-%m-%d)
TAG="snapshot-$DATE-$SHA7"
git rev-parse -q --verify "refs/tags/$TAG" >/dev/null &&
  die "$TAG exists: this commit has been snapshotted today already"

# -- 1. the gate, on exactly this commit -----------------------------------
echo "make-release: running the gate on $SRCBRANCH@$SHA7"
mkdir -p build
if ! ./tools/verify.sh >build/release-verify.log 2>&1; then
  tail -5 build/release-verify.log >&2
  die "tools/verify.sh failed; no snapshot of a red tree (log: build/release-verify.log)"
fi

# -- 2. the artifacts that are not already built by the gate ---------------
# Every S1 kernel's trace and both Perfetto views, not only vadd's.
SKEL=build/skel/ccv-skel
[ -x "$SKEL" ] || die "no $SKEL after the gate"
KERNELS=$(ls -d test/golden/*/ | xargs -n1 basename)
for k in $KERNELS; do
  "$SKEL" --kernel "test/golden/$k/oracle.jsonl" --trace "build/rel_$k.ccvtrace" \
    >"build/rel_$k.log" 2>&1 || die "kernel $k did not run clean"
  python3 tools/trace2perfetto.py "build/rel_$k.ccvtrace" --by=instr \
    -o "build/rel_$k.by_instr.json" >/dev/null || die "Perfetto view of $k failed"
  python3 tools/trace2perfetto.py "build/rel_$k.ccvtrace" \
    -o "build/rel_$k.by_unit.json" >/dev/null || die "Perfetto view of $k failed"
done
"$SKEL" --dump-wiring build/rel_wiring.txt >/dev/null || die "wiring dump failed"

# -- 3. stage the tree -------------------------------------------------------
STAGE=$(mktemp -d)
WT=$(mktemp -d)
trap 'rm -rf "$STAGE"; git worktree remove --force "$WT" >/dev/null 2>&1; rm -rf "$WT"' EXIT
git archive "$SHA" | tar -x -C "$STAGE"
for d in rtl/generated sim/generated; do
  mkdir -p "$STAGE/$d"
  cp -p "$d"/* "$STAGE/$d/"
done
A="$STAGE/release"
mkdir -p "$A/kernels"
cp build/release-verify.log "$A/verify.log"
cp build/rel_wiring.txt "$A/wiring.txt"
for k in $KERNELS; do
  cp "build/rel_$k.log" "$A/kernels/$k.log"
  cp "build/rel_$k.ccvtrace" "$A/kernels/$k.ccvtrace"
  cp "build/rel_$k.by_instr.json" "$A/kernels/$k.by_instr.json"
  cp "build/rel_$k.by_unit.json" "$A/kernels/$k.by_unit.json"
done
big=$(find "$A" -type f -size +"$MAXFILE"c)
[ -z "$big" ] || die "artifact over the $((MAXFILE / 1024 / 1024)) MB cap: $big"
total=$(du -sb "$A" | cut -f1)
[ "$total" -le "$MAXTOTAL" ] || die "release/ is $total bytes, over the cap"

ver() { "$@" 2>&1 | head -1; }
{
  echo "# Snapshot $TAG"
  echo
  echo "**A generated, read-only snapshot. Do not edit or merge it.** The source"
  echo "is \`$SRCBRANCH\` at \`$SHA\`, and this branch is rebuilt from source by"
  echo "\`tools/make-release.sh\`; nothing here flows back."
  echo
  echo "What is here beyond the source tree at that commit:"
  echo
  echo "- **Generated files, at their real paths:** \`rtl/generated/\` (interface"
  echo "  typedefs in \`ccv_interfaces.svh\`, parameter packages, the checker"
  echo "  bank, event ids) and \`sim/generated/\`. On the development branch"
  echo "  these are build products and gitignored."
  echo "- **\`release/\`:** the gate log (\`verify.log\`), the C++ skeleton's"
  echo "  wiring dump, and for each S1 kernel its run summary, event trace"
  echo "  (\`.ccvtrace\`) and two Perfetto views -- open the \`.json\` files at"
  echo "  https://ui.perfetto.dev."
  echo
  echo "| | |"
  echo "|---|---|"
  echo "| Source | \`$SRCBRANCH\` @ \`$SHA\` |"
  echo "| Built | $DATE (UTC) |"
  echo "| Gate | \`tools/verify.sh\`: $(grep -A1 '== result ==' build/release-verify.log | tail -1 | xargs) |"
  echo "| Verilator | $(ver verilator --version) |"
  echo "| Icarus | $(ver iverilog -V) |"
  echo "| Yosys | $(ver yosys -V) |"
  echo
  echo "## Kernels"
  echo
  echo "| Kernel | Result |"
  echo "|---|---|"
  for k in $KERNELS; do
    echo "| \`$k\` | \`$(grep '^KERNEL' "build/rel_$k.log" | sed 's/^KERNEL //')\` |"
  done
  echo
  echo "## Manifest of release/"
  echo
  echo '```'
  (cd "$STAGE" && find release -type f | sort | xargs sha256sum)
  echo '```'
} >"$STAGE/SNAPSHOT.md"

# -- 4. commit it on the release branch --------------------------------------
PARENT=$(git rev-parse -q --verify "refs/heads/$BRANCH" ||
         git rev-parse -q --verify "refs/remotes/origin/$BRANCH" || true)
rm -rf "$WT"
git worktree add --detach "$WT" "$SHA" >/dev/null 2>&1 || die "worktree failed"
(
  cd "$WT"
  # The snapshot's tree is exactly the stage: clear the checkout, copy in.
  git rm -rq --cached . >/dev/null
  find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  cp -a "$STAGE"/. .
  git add -A -f .
  TREE=$(git write-tree)
  MSG=$(printf 'Snapshot of %s@%s\n\nGenerated by tools/make-release.sh: the source tree at %s,\nits generated files, and the build artifacts under release/.\nRead-only; never merged back.\n' "$SRCBRANCH" "$SHA7" "$SHA")
  if [ -n "$PARENT" ]; then
    NEW=$(git commit-tree "$TREE" -p "$PARENT" -m "$MSG")
  else
    NEW=$(git commit-tree "$TREE" -m "$MSG")
  fi
  git update-ref "refs/heads/$BRANCH" "$NEW"
  git tag "$TAG" "$NEW"
) || die "commit failed"

NFILES=$(git ls-tree -r --name-only "$BRANCH" | wc -l)
echo "make-release: $TAG on branch $BRANCH ($NFILES files, release/ $((total / 1024)) KB)"
if [ "$PUSH" = 1 ]; then
  git push -u origin "$BRANCH" && git push origin "$TAG" ||
    die "push failed; the snapshot is local ($BRANCH, $TAG)"
  echo "make-release: pushed $BRANCH and $TAG"
else
  echo "make-release: local only; publish with: git push -u origin $BRANCH && git push origin $TAG"
fi
