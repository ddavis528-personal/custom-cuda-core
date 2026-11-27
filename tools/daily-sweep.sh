#!/usr/bin/env bash
# The daily sweep's repository half (the register half needs the docs tools,
# so it stays in the model's turn): merge every remote branch but release
# and gate-scratch/*, regen and commit, the release (whose gate is the push's gate), push, clear.
#
#   tools/daily-sweep.sh [--branches=a,b] [--no-push] [--skip=b1,b2]
#
# --skip leaves those branches unmerged on purpose (a conflict for their
# owner to settle) and lets the release through without them. The snapshot
# is skipped when release's latest is already of this exact commit.
#
# Under CCV_RESUME=1 (a sweep a restart killed, IS-27), a branch that moved
# since is left unmerged, as --skip would, so the tree is the one the killed
# gate ran and verify.sh carries its passed sections over; the next sweep
# takes those commits.
#
# A merge whose only conflicts are generated files takes ours and lets regen
# rewrite them; any other conflict aborts that merge and stops the sweep with
# the files named, exit 3, for the session to resolve. Prints a few lines.
#
# Branches merge in order of fewest merge bases with the tip (RA, 2026-11-19;
# TI-499). A branch with several bases can send the default strategy's
# recursive virtual-ancestor build past half an hour (11-20: OA's branch, four
# bases, 25 min and counting; resolve took 0.15 s). So each merge has
# CCV_SWEEP_MERGE_TIMEOUT seconds (default 300); past it the attempt is
# discarded and tools/sweep-merge.sh merges on the newest base alone.
set -uo pipefail
cd "$(dirname "$0")/.."
ME=daily-sweep
. tools/push-lib.sh
PUSH=1 SKIP=""
for a in "$@"; do
  case "$a" in
    --branches=*) CCV_PUSH_BRANCHES=${a#--branches=} ;;
    --no-push)    PUSH=0 ;;
    --skip=*)     SKIP=${a#--skip=} ;;
    *) echo "usage: $0 [--branches=a,b] [--no-push] [--skip=b1,b2]" >&2; exit 2 ;;
  esac
done
# Without push branches the sweep would gate and then fail to push: say so
# now, not after the gate.
[ "$PUSH" = 1 ] && { branches >/dev/null || exit 2; }
# A long run never runs under its caller (tools/detach.sh; DA, 2026-11-13):
# it detaches and returns; tools/gate-wait.sh waits for it.
. "$(dirname "$0")/detach.sh"; ccv_detach "$0" "$@"

GENERATED='^(sim/generated/|rtl/generated/|rtl/top/|docs/payload-spec\.md$|docs/trust-report\.md$|docs/walkthrough\.md$)'
clean_tree
with_retry git fetch -q --prune origin || die "cannot fetch origin"
WHEN=$(TZ=America/Los_Angeles date +'%Y-%m-%d, %H:%M')
merged=""
# Each candidate with its merge-base count, fewest first (ties by name).
order=$(for rb in $(git for-each-ref --format='%(refname:short)' refs/remotes/origin); do
  echo "$(git merge-base --all HEAD "$rb" 2>/dev/null | wc -l) $rb"
done | sort -k1,1n -k2,2 | awk '{print $2}')
# One merge, at most CCV_SWEEP_MERGE_TIMEOUT seconds with the default
# strategy; past it, tools/sweep-merge.sh: one merge base, conflicts settled
# by history only (AR 425, TI-595; 11-27's ten-base branch in 10 s, where
# recursive ran hours and resolve refused). A file it cannot settle is left
# in UNSETTLED for the caller, HEAD at the tip. The tree was clean before it
# (clean_tree), so a timed-out attempt is discarded with a hard reset.
UNSETTLED=""
merge_one() {
  local rb=$1 msg=$2 head st
  UNSETTLED=""; head=$(git rev-parse HEAD)
  timeout "${CCV_SWEEP_MERGE_TIMEOUT:-300}" git merge -q --no-ff --no-edit -m "$msg" "$rb" >/dev/null 2>&1
  st=$?
  [ $st = 124 ] || return $st
  git merge --abort >/dev/null 2>&1; git reset -q --hard "$head"
  say "merging $rb took over ${CCV_SWEEP_MERGE_TIMEOUT:-300}s ($(git merge-base --all HEAD "$rb" | wc -l) merge bases); one-base merge (tools/sweep-merge.sh)"
  UNSETTLED=$(CCV_GENERATED_RE="$GENERATED" tools/sweep-merge.sh "$rb" "$msg (one base, settled by history)")
  st=$?
  [ $st = 0 ] && return 0
  git reset -q --hard "$head"
  [ -n "$UNSETTLED" ] || UNSETTLED="(tools/sweep-merge.sh failed, exit $st)"
  return 1
}
for rb in $order; do
  b=${rb#origin/}
  # gate-scratch/*: unverified commits and exports in transit (DA, 2026-11-01).
  case "$b" in HEAD|origin|release|gate-scratch/*) continue ;; esac
  case ",$SKIP," in *",$b,"*) continue ;; esac
  n=$(git rev-list --count "HEAD..$rb")
  [ "$n" -gt 0 ] || continue
  if [ "${CCV_RESUME:-0}" = 1 ]; then
    SKIP="${SKIP:+$SKIP,}$b"; say "resume: $b moved ($n), left to the next sweep"; continue
  fi
  pre=$(git rev-parse HEAD)
  if ! merge_one "$rb" "Merge $rb (daily sweep $WHEN)"; then
    other=$(git diff --name-only --diff-filter=U | grep -Ev "$GENERATED" || true)
    # sweep-merge's unsettled files (merge_one's fallback) are never concluded here.
    [ -n "$UNSETTLED" ] && other=$UNSETTLED
    if [ -n "$other" ]; then
      git merge --abort >/dev/null 2>&1
      git reset -q --hard "$pre"
      die "merging $rb conflicts outside generated files; resolve it, or rerun with --skip=$b:
$(printf '  %s\n' $other)" 3
    fi
    git diff --name-only --diff-filter=U | xargs -r git checkout --ours --
    git diff --name-only --diff-filter=U | xargs -r git add --
    git commit -q --no-edit || die "cannot conclude the merge of $rb"
  fi
  merged="$merged $b($n)"
done
say "merged:${merged:- nothing new}"
regen_commit
[ "$PUSH" = 1 ] && ancestry
RLOG="$LOGDIR/release-$STAMP.log"
PUSH_SHA=$(git rev-parse HEAD)
if git log -1 --format=%B origin/release 2>/dev/null | grep -q "source tree at $PUSH_SHA"; then
  say "release's latest snapshot is already of $(git rev-parse --short HEAD), and its gate passed: no new snapshot"
  [ "$PUSH" = 1 ] && { ancestry; push_all; }
  clear_build; exit 0
fi
say "release and its gate on $(git rev-parse --short HEAD) (log: $RLOG)"
if ! ./tools/make-release.sh $([ "$PUSH" = 1 ] && echo --push) \
     $([ -n "$SKIP" ] && echo "--allow-unmerged=$SKIP") >"$RLOG" 2>&1; then
  [ -f build/release-verify.log ] && python3 tools/gate-summary.py build/release-verify.log
  tail -3 "$RLOG"
  die "make-release failed; nothing pushed"
fi
grep -E '^make-release:' "$RLOG" | tail -3
if [ "$PUSH" = 1 ]; then
  ancestry
  push_all
fi
clear_build
