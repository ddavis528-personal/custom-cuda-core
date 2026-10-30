#!/usr/bin/env bash
# The daily sweep's repository half (the register half needs the docs tools,
# so it stays in the model's turn): merge every remote branch but release,
# regen and commit, the release (whose gate is the push's gate), push, clear.
#
#   tools/daily-sweep.sh [--branches=a,b] [--no-push] [--skip=b1,b2]
#
# --skip leaves those branches unmerged on purpose (a conflict for their
# owner to settle) and lets the release through without them. The snapshot
# is skipped when release's latest is already of this exact commit.
#
# A merge whose only conflicts are generated files takes ours and lets regen
# rewrite them; any other conflict aborts that merge and stops the sweep with
# the files named, exit 3, for the session to resolve. Prints a few lines.
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
GENERATED='^(sim/generated/|rtl/generated/|rtl/top/|docs/payload-spec\.md$|docs/trust-report\.md$|docs/walkthrough\.md$)'
clean_tree
with_retry git fetch -q --prune origin || die "cannot fetch origin"
WHEN=$(TZ=America/Los_Angeles date +'%Y-%m-%d, %H:%M')
merged=""
for rb in $(git for-each-ref --format='%(refname:short)' refs/remotes/origin); do
  b=${rb#origin/}
  case "$b" in HEAD|origin|release) continue ;; esac
  case ",$SKIP," in *",$b,"*) continue ;; esac
  n=$(git rev-list --count "HEAD..$rb")
  [ "$n" -gt 0 ] || continue
  if ! git merge -q --no-ff --no-edit -m "Merge $rb (daily sweep $WHEN)" "$rb" >/dev/null 2>&1; then
    other=$(git diff --name-only --diff-filter=U | grep -Ev "$GENERATED" || true)
    if [ -n "$other" ]; then
      git merge --abort
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
