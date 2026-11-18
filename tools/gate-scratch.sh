#!/usr/bin/env bash
# A split gate's transport (OI-102; DA, 2026-11-01): the commit to gate goes
# out on gate-scratch/<PREFIX> before it is verified, and an export comes
# back on gate-scratch/<PREFIX>-export. Nothing merges or gates these
# branches: every sweep skips gate-scratch/* and CI ignores them. The owner
# force-pushes them freely; they are never deleted, since a session's git
# proxy refuses a branch deletion (HTTP 403), so each send overwrites the last.
#
#   tools/gate-scratch.sh send-commit <PREFIX>            HEAD to gate-scratch/<PREFIX>
#   tools/gate-scratch.sh fetch-commit <PREFIX> <sha>     fetch it, check out <sha> detached
#   tools/gate-scratch.sh send-export <PREFIX> <x.tgz>    a gate-export.sh file, to <PREFIX>-export
#   tools/gate-scratch.sh fetch-export <PREFIX> <out.tgz> fetch it back
#
# An export goes as a one-file commit with no parent. GitHub refuses a file
# over 100 MB, so an export with --cache may not fit: send the logs alone.
set -uo pipefail
cd "$(dirname "$0")/.."
ME=gate-scratch
. tools/push-lib.sh
usage() { sed -n '9,12p' "$0" | sed 's/^# //' >&2; exit 2; }
[ $# -ge 2 ] || usage
cmd=$1 p=$2
case "$p" in *[!A-Za-z0-9_-]*|"") die "bad prefix: $p" 2 ;; esac
br=gate-scratch/$p ex=gate-scratch/$p-export
case "$cmd" in
  send-commit)
    sha=$(git rev-parse HEAD)
    with_retry git push -q -f origin "$sha:refs/heads/$br" || die "push to $br refused"
    say "$(git rev-parse --short "$sha") on $br (unverified; nothing merges it)" ;;
  fetch-commit)
    [ $# -eq 3 ] || usage
    clean_tree
    with_retry git fetch -q origin "$br" || die "cannot fetch $br"
    git cat-file -e "$3^{commit}" 2>/dev/null || die "$3 is not on $br"
    git checkout -q --detach "$3" || die "cannot check out $3"
    say "$(git rev-parse --short HEAD) checked out detached, from $br" ;;
  send-export)
    [ $# -eq 3 ] && [ -f "$3" ] || usage
    [ "$(stat -c %s "$3")" -lt $((100 << 20)) ] || die "$3 is over GitHub's 100 MB a file; export without --cache"
    blob=$(git hash-object -w "$3")
    tree=$(printf '100644 blob %s\texport.tgz\n' "$blob" | git mktree)
    c=$(git commit-tree "$tree" -m "gate-scratch: export from $p ($(basename "$3"))")
    with_retry git push -q -f origin "$c:refs/heads/$ex" || die "push to $ex refused"
    say "$(basename "$3") on $ex" ;;
  fetch-export)
    [ $# -eq 3 ] || usage
    with_retry git fetch -q origin "$ex" || die "cannot fetch $ex"
    git show FETCH_HEAD:export.tgz > "$3" || die "no export.tgz on $ex"
    say "$ex to $3 ($(stat -c %s "$3") bytes)" ;;
  *) usage ;;
esac
