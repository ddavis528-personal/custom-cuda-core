# Shared by tools/gate-push.sh and tools/daily-sweep.sh; sourced, never run.
# A session's routine moves as one command each, so a turn spends one tool
# call on them, not ten, and reads a summary, not the logs (DA, 2026-10-30).
#
# CCV_PUSH_BRANCHES  the branches this session pushes to, comma-separated
#                    (TI: ccr-183cc441-doowtf,claude/custom-cuda-core-infra-6msg93)
# CCV_LOGDIR         where logs go; outside build/, which the gate clears
#                    (default ~/ccv-logs)

LOGDIR=${CCV_LOGDIR:-$HOME/ccv-logs}
mkdir -p "$LOGDIR"
STAMP=$(date -u +%Y%m%d-%H%M)
TRAILER=${CCV_TRAILER:-}

say() { printf '%s: %s\n' "$ME" "$*"; }
die() { printf '%s: %s\n' "$ME" "$1" >&2; exit "${2:-1}"; }

# The commit trailers, from the last commit that carries them, so a script's
# commit is signed as the session's own are.
trailers() {
  [ -n "$TRAILER" ] && { printf '%s\n' "$TRAILER"; return; }
  git log -50 --format=%B | grep -m1 '^Co-Authored-By:' || true
  git log -50 --format=%B | grep -m1 '^Claude-Session:' || true
}

clean_tree() {
  [ -z "$(git status --porcelain --untracked-files=no)" ] ||
    die "the working tree has uncommitted changes; commit them first"
}

# with_retry <cmd...>: a network command, retried at 2, 4, 8, 16 s.
with_retry() {
  local d
  for d in 2 4 8 16 0; do
    "$@" && return 0
    [ "$d" = 0 ] && return 1
    say "retrying in ${d}s: $*"; sleep "$d"
  done
}

branches() {
  [ -n "${CCV_PUSH_BRANCHES:-}" ] || die "set CCV_PUSH_BRANCHES (or --branches=a,b)"
  printf '%s\n' "$CCV_PUSH_BRANCHES" | tr ',' '\n' | sed '/^$/d'
}

# Every push branch must be an ancestor of the commit pushed ($PUSH_SHA, set
# where the gate ran; HEAD before that): a push never drops work.
ancestry() {
  local b at=${PUSH_SHA:-HEAD}
  with_retry git fetch -q origin $(branches | sed 's|.*|&:refs/remotes/origin/&|') 2>/dev/null ||
    with_retry git fetch -q origin || die "cannot fetch origin"
  for b in $(branches); do
    git rev-parse -q --verify "refs/remotes/origin/$b" >/dev/null || continue  # a new branch
    git merge-base --is-ancestor "origin/$b" "$at" ||
      die "origin/$b has commits $at lacks ($(git rev-list --count $at..origin/$b)); merge it first"
  done
}

# Pushes $PUSH_SHA, the commit the gate ran on, whatever HEAD is by now.
push_all() {
  local b at=${PUSH_SHA:?the gated commit}
  for b in $(branches); do
    with_retry git push -q origin "$at:refs/heads/$b" || die "push to $b failed"
    say "pushed $(git rev-parse --short "$at") to $b"
  done
}

# regen, then commit what it changed (DA, 2026-10-23).
regen_commit() {
  ./tools/regen.sh >"$LOGDIR/regen-$STAMP.log" 2>&1 ||
    die "tools/regen.sh failed (log: $LOGDIR/regen-$STAMP.log)"
  local gen="sim/generated rtl/generated rtl/top docs/payload-spec.md docs/trust-report.md docs/walkthrough.md"
  local changed
  changed=$(git status --porcelain -- $gen | cut -c4-)
  if [ -n "$changed" ]; then
    printf '%s
' "$changed" | xargs -r git add -A --
    git commit -q -F - <<MSG || die "cannot commit regen's output"
regen: generated files for $(git rev-parse --short HEAD)

$(trailers)
MSG
    say "committed regen's changes: $(git diff --stat HEAD~1 | tail -1)"
  fi
  clean_tree
}

# Build products, minus the compiler snapshot and its fetch cache.
clear_build() {
  find build -mindepth 1 -maxdepth 1 ! -name compiler ! -name compiler.git -exec rm -rf {} + 2>/dev/null
  say "cleared build/ (kept compiler, compiler.git)"
}
