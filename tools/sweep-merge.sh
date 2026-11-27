#!/usr/bin/env bash
# One branch merged on a single merge base, its conflicts settled only by
# history (AR 425, TI-595): the sweep's merge for a branch whose criss-cross
# history makes git's own merge too slow (11-27: ten merge bases, recursive
# ran 5.5 h on one branch; resolve refuses past 8). Every agent's sweep runs
# this one procedure (tools/daily-sweep.sh calls it).
#
#   tools/sweep-merge.sh <theirs> <message>   merge into HEAD; exit 0
#   tools/sweep-merge.sh --selftest           its cases and controls
#
# (1) The base is the newest of `git merge-base --all HEAD theirs`, by commit
#     time. (2) `git merge-tree --write-tree` merges on it. (3) Each
#     conflicted file is settled by its history alone: theirs where HEAD's
#     exact blob appears in theirs' history of that file (theirs grew from
#     ours), ours where theirs' blob appears in ours'; a generated file takes
#     ours (regen rewrites it). Anything else is unsettled: nothing changes,
#     the files are printed one per line, exit 1. (4) A merge commit with
#     parents HEAD and theirs; HEAD moves to it (the tree must be clean).
# One base's cost: a change one side made and later reverted can come back
# from the other; the full gate after the sweep is there to catch it.
set -uo pipefail
GENERATED=${CCV_GENERATED_RE:-'^(sim/generated/|rtl/generated/|rtl/top/|docs/payload-spec\.md$|docs/trust-report\.md$|docs/walkthrough\.md$)'}

# Every blob the file has had in rev's history (--full-history: across merges).
blobs_of() { git log --raw --no-abbrev --format= --full-history "$1" -- "$2" | awk '{print $3; print $4}'; }

merge() {
  local theirs=$1 msg=$2 base out tree f o t idx new unsettled=""
  base=$(git merge-base --all HEAD "$theirs" | while read -r c; do
    echo "$(git log -1 --format=%ct "$c") $c"; done | sort -rn | head -1 | cut -d' ' -f2)
  [ -n "$base" ] || { echo "sweep-merge: no merge base with $theirs" >&2; return 2; }
  out=$(git merge-tree --write-tree --name-only --no-messages --merge-base="$base" HEAD "$theirs")
  tree=$(printf '%s\n' "$out" | head -1)
  idx=$(mktemp); trap 'rm -f "$idx"' RETURN
  GIT_INDEX_FILE=$idx git read-tree "$tree"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    o=$(git rev-parse -q --verify "HEAD:$f" 2>/dev/null || true)
    t=$(git rev-parse -q --verify "$theirs:$f" 2>/dev/null || true)
    if printf '%s\n' "$f" | grep -Eq "$GENERATED"; then :          # ours
    elif [ -n "$o" ] && [ -n "$t" ] && blobs_of "$theirs" "$f" | grep -qx "$o"; then
      GIT_INDEX_FILE=$idx git update-index --cacheinfo "$(git ls-tree "$theirs" -- "$f" | cut -d' ' -f1),$t,$f"
      continue
    elif [ -n "$o" ] && [ -n "$t" ] && blobs_of HEAD "$f" | grep -qx "$t"; then :   # ours
    else unsettled="$unsettled$f"$'\n'; continue
    fi
    if [ -n "$o" ]; then
      GIT_INDEX_FILE=$idx git update-index --add --cacheinfo "$(git ls-tree HEAD -- "$f" | cut -d' ' -f1),$o,$f"
    else
      GIT_INDEX_FILE=$idx git update-index --force-remove -- "$f"
    fi
  done < <(printf '%s\n' "$out" | tail -n +2)
  if [ -n "$unsettled" ]; then printf '%s' "$unsettled"; return 1; fi
  tree=$(GIT_INDEX_FILE=$idx git write-tree) || return 2
  new=$(git commit-tree "$tree" -p HEAD -p "$theirs" -m "$msg") || return 2
  git merge -q --ff-only "$new" >/dev/null || return 2
}

selftest() {
  local d fails=0 me; me=$(readlink -f "$0"); d=$(mktemp -d); trap 'rm -rf "$d"' RETURN
  ok()  { if eval "$2"; then echo "  ok: $1"; else echo "  FAIL: $1"; fails=$((fails+1)); fi; }
  ( cd "$d" && git init -q -b main && git config user.email t@t && git config user.name t
    mkdir -p rtl/top
    printf 'a1\n' >a; printf 'b1\n' >b; printf 'g1\n' >rtl/top/g; printf 'c1\n' >c
    git add . && git commit -qm base
    # Criss-cross: x and y each merge the other's first change, giving two bases.
    git checkout -qb x; printf 'a1\nx\n' >a; git commit -qam x1
    git checkout -q main; git checkout -qb y; printf 'b1\ny\n' >b; git commit -qam y1
    git checkout -q x; git merge -q --no-edit y; git checkout -q y; git merge -q --no-edit x~1
    # Then: y grows a from x's text (a's blob on x is in y's history),
    # both sides change a generated file, and c differs only on y.
    git checkout -q x; printf 'g-x\n' >rtl/top/g; git commit -qam x2
    git checkout -q y; printf 'a1\nx\ny2\n' >a; printf 'g-y\n' >rtl/top/g; printf 'c-y\n' >c; git commit -qam y2
    git checkout -q x; printf 'a1\nx\n' >a; git commit -qam x-noop --allow-empty
    git branch -q x-ok
    # A true conflict: both sides change c's one line differently.
    git checkout -qb x-bad; printf 'c-x\n' >c; git commit -qam x-bad
    git checkout -q x-ok ) >/dev/null 2>&1
  cd "$d" || return 1
  ok "two merge bases" '[ "$(git merge-base --all x-ok y | wc -l)" -ge 2 ]'
  local nb; nb=$(for c in $(git merge-base --all x-ok y); do echo "$(git log -1 --format=%ct "$c") $c"; done | sort -rn | head -1 | cut -d" " -f2)
  ok "a and the generated file conflict on one base" \
    '[ "$(git merge-tree --write-tree --name-only --no-messages --merge-base=$nb x-ok y | tail -n +2 | sort | tr "\n" " ")" = "a rtl/top/g " ]'
  git checkout -q x-ok; "$me" y "m" >/dev/null 2>&1; local st=$?
  ok "settled by history: exit 0" '[ $st = 0 ]'
  ok "theirs where ours is in their history" '[ "$(cat a)" = "$(printf "a1\nx\ny2")" ]'
  ok "generated file keeps ours" '[ "$(cat rtl/top/g)" = g-x ]'
  ok "clean one-sided change taken" '[ "$(cat c)" = c-y ]'
  ok "two parents" '[ "$(git rev-list --parents -1 HEAD | wc -w)" = 3 ]'
  # Negative control: c changed on both sides with neither in the other's
  # history; nothing may change and c is named.
  git checkout -q x-bad; local pre; pre=$(git rev-parse HEAD)
  local un; un=$("$me" y "m" 2>/dev/null); st=$?
  ok "control: a true conflict stops (exit 1)" '[ $st = 1 ]'
  ok "control: names the file" '[ "$un" = c ]'
  ok "control: HEAD unchanged" '[ "$(git rev-parse HEAD)" = "$pre" ] && git diff --quiet'
  [ $fails = 0 ] && echo "sweep-merge selftest: PASS" || { echo "sweep-merge selftest: $fails FAIL"; return 1; }
}

case "${1:-}" in
  --selftest) selftest ;;
  ""|-*) echo "usage: $0 <theirs> <message> | --selftest" >&2; exit 2 ;;
  *) [ $# = 2 ] || { echo "usage: $0 <theirs> <message>" >&2; exit 2; }; merge "$1" "$2" ;;
esac
