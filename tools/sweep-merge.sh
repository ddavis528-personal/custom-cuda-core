#!/usr/bin/env bash
# One branch merged over one merge base (a virtual one when there are
# several), its conflicts settled only by history (AR 425, RI-65, TI-599):
# the sweep's merge for a branch whose criss-cross
# history makes git's own merge too slow (11-27: ten merge bases, recursive
# ran 5.5 h on one branch; resolve refuses past 8). Every agent's sweep runs
# this one procedure (tools/daily-sweep.sh calls it).
#
#   tools/sweep-merge.sh <theirs> <message>   merge into HEAD; exit 0
#   tools/sweep-merge.sh --selftest           its cases and controls
#
# (1) The base is the one merge base, or with several a virtual base: the
#     bases merged flat over their octopus base (RI-65). (2) `git
#     merge-tree --write-tree` merges on it. (3) Each
#     conflicted file is settled by its history alone: theirs where HEAD's
#     exact blob appears in theirs' history of that file (theirs grew from
#     ours), ours where theirs' blob appears in ours'; a generated file takes
#     ours (regen rewrites it). Anything else is unsettled: nothing changes,
#     the files are printed one per line, exit 1. (4) A merge commit with
#     parents HEAD and theirs; HEAD moves to it (the tree must be clean).
# The virtual base holds every base's changes, so a change one side made
# and later reverted does not come back from the other (a single newest
# base's cost, 450d4814's first form).
set -uo pipefail
GENERATED=${CCV_GENERATED_RE:-'^(sim/generated/|rtl/generated/|rtl/top/|docs/payload-spec\.md$|docs/trust-report\.md$|docs/walkthrough\.md$)'}

# Every blob the file has had in rev's history (--full-history: across merges).
blobs_of() { git log --raw --no-abbrev --format= --full-history "$1" -- "$2" | awk '{print $3; print $4}'; }

# The merge base: the one base, or with several the virtual base V (RI-65):
# the bases merged flat, each onto V over their octopus base, every step a
# tree wrapped as a commit (a conflict's markers stay in V, as git's own
# recursive merge leaves them). Prints V's commit.
vbase() {
  local bases n v b ob t
  bases=$(git merge-base --all "$1" "$2"); n=$(printf '%s\n' "$bases" | grep -c .)
  [ "$n" -le 1 ] && { printf '%s\n' "$bases"; return 0; }
  # shellcheck disable=SC2086
  ob=$(git merge-base --octopus $bases) || return 1
  v=$(printf '%s\n' "$bases" | head -1)
  for b in $(printf '%s\n' "$bases" | tail -n +2); do
    t=$(git merge-tree --write-tree --no-messages --merge-base="$ob" "$v" "$b" | head -1)
    [ -n "$t" ] || return 1
    v=$(git commit-tree "$t" -p "$v" -p "$b" -m "sweep-merge virtual base") || return 1
  done
  printf '%s\n' "$v"
}

merge() {
  local theirs=$1 msg=$2 base out tree f o t idx new unsettled=""
  base=$(vbase HEAD "$theirs") || return 2
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
  # commit-tree ignores commit.gpgsign: sign as `git commit` would (AR 430),
  # or GitHub shows the sweep's merge Unverified.
  local sign=()
  [ "$(git config --bool commit.gpgsign 2>/dev/null)" = true ] && sign=(-S)
  new=$(git commit-tree "${sign[@]}" "$tree" -p HEAD -p "$theirs" -m "$msg") || return 2
  git merge -q --ff-only "$new" >/dev/null || return 2
}

selftest() {
  local d fails=0 me; me=$(readlink -f "$0"); d=$(mktemp -d); trap 'rm -rf "$d"' RETURN
  ok()  { if eval "$2"; then echo "  ok: $1"; else echo "  FAIL: $1"; fails=$((fails+1)); fi; }
  # Each commit a second apart, so "newest base" is defined for the
  # single-base comparison below.
  ( cd "$d" && git init -q -b main && git config user.email t@t && git config user.name t && git config commit.gpgsign false
    n=0; tick() { n=$((n+1)); export GIT_AUTHOR_DATE="@$((1700000000+n)) +0000" GIT_COMMITTER_DATE="@$((1700000000+n)) +0000"; }
    git() { case "$1" in commit|merge) tick ;; esac; command git "$@"; }
    mkdir -p rtl/top
    for f in a b c e r; do printf '%s1\n' $f >$f; done; printf 'g1\n' >rtl/top/g
    git add . && git commit -qm base
    # Criss-cross: x and y each merge the other's first change, giving two bases.
    git checkout -qb x; printf 'a1\nx\n' >a; printf 'r1\nx\n' >r; git commit -qam x1
    git checkout -q main; git checkout -qb y; printf 'b1\ny\n' >b; git commit -qam y1
    git checkout -q x; git merge -q --no-edit y; git checkout -q y; git merge -q --no-edit x~1
    # Then x reverts r and changes e; y copies x's e (a cherry-pick) and
    # grows it; both change a generated file; c differs only on y.
    git checkout -q x; printf 'g-x\n' >rtl/top/g; printf 'r1\n' >r; printf 'e1\nx\n' >e; git commit -qam x2
    git checkout -q y; printf 'g-y\n' >rtl/top/g; printf 'c-y\n' >c; printf 'e1\nx\n' >e; git commit -qam y2
    printf 'e1\nx\ny3\n' >e; git commit -qam y3
    git checkout -q x; git branch -q x-ok
    # A true conflict: both sides change c's one line differently.
    git checkout -qb x-bad; printf 'c-x\n' >c; git commit -qam x-bad
    git checkout -q x-ok ) >/dev/null 2>&1
  cd "$d" || return 1
  ok "two merge bases" '[ "$(git merge-base --all x-ok y | wc -l)" -ge 2 ]'
  local nb vb; nb=$(for c in $(git merge-base --all x-ok y); do echo "$(git log -1 --format=%ct "$c") $c"; done | sort -rn | head -1 | cut -d" " -f2)
  vb=$(vbase x-ok y)
  ok "virtual base: e and the generated file conflict" \
    '[ "$(git merge-tree --write-tree --name-only --no-messages --merge-base=$vb x-ok y | tail -n +2 | sort | tr "\n" " ")" = "e rtl/top/g " ]'
  ok "control: the newest base alone brings x's reverted r back" \
    '[ "$(git cat-file -p "$(git merge-tree --write-tree --no-messages --merge-base=$nb x-ok y | head -1):r")" = "$(printf "r1\nx")" ]'
  git checkout -q x-ok; "$me" y "m" >/dev/null 2>&1; local st=$?
  ok "settled by history: exit 0" '[ $st = 0 ]'
  ok "theirs where ours is in their history" '[ "$(cat e)" = "$(printf "e1\nx\ny3")" ]'
  ok "the revert stays reverted" '[ "$(cat r)" = r1 ]'
  ok "generated file keeps ours" '[ "$(cat rtl/top/g)" = g-x ]'
  ok "clean one-sided change taken" '[ "$(cat c)" = c-y ]'
  ok "two parents" '[ "$(git rev-list --parents -1 HEAD | wc -w)" = 3 ]'
  ok "unsigned when commit.gpgsign is off" '! git cat-file -p HEAD | grep -q "^gpgsig "'
  # Signed when commit.gpgsign is on (AR 430), through a stand-in signer:
  # the merge carries a gpgsig header.
  printf '#!/bin/sh\ncat >/dev/null\necho "[GNUPG:] SIG_CREATED D 1 8 00 0 X" >&2\nprintf -- "-----BEGIN PGP SIGNATURE-----\\nselftest\\n-----END PGP SIGNATURE-----\\n"\n' >"$d/.signer"
  chmod +x "$d/.signer"
  git -c advice.detachedHead=false checkout -q --detach HEAD~1
  git config gpg.format openpgp; git config gpg.program "$d/.signer"; git config user.signingkey X
  git config commit.gpgsign true
  "$me" y "m" >/dev/null 2>&1; st=$?
  ok "signed when commit.gpgsign is on" '[ $st = 0 ] && git cat-file -p HEAD | grep -q "^gpgsig "'
  git config commit.gpgsign false
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
