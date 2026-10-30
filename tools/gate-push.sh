#!/usr/bin/env bash
# Regen, commit, the clean gate, an ancestry check, push, clear build: one
# command for the routine every push takes (CLAUDE.md, The gate).
#
#   tools/gate-push.sh [--branches=a,b] [--no-push] [--keep-build]
#
# Prints a few lines: regen's commit if any, the gate's summary
# (tools/gate-summary.py), what it pushed. Logs go to $CCV_LOGDIR. Exit 1 on
# any refusal or a red gate, with nothing pushed.
set -uo pipefail
cd "$(dirname "$0")/.."
ME=gate-push
. tools/push-lib.sh
PUSH=1 KEEP=0
for a in "$@"; do
  case "$a" in
    --branches=*) CCV_PUSH_BRANCHES=${a#--branches=} ;;
    --no-push)    PUSH=0 ;;
    --keep-build) KEEP=1 ;;
    *) echo "usage: $0 [--branches=a,b] [--no-push] [--keep-build]" >&2; exit 2 ;;
  esac
done
clean_tree
[ "$PUSH" = 1 ] && ancestry           # fail before the gate, not after it
regen_commit
PUSH_SHA=$(git rev-parse HEAD)
SHA7=$(git rev-parse --short HEAD)
VLOG="$LOGDIR/verify-$SHA7-$STAMP.log"
say "gate on $SHA7 (log: $VLOG)"
./tools/verify.sh >"$VLOG" 2>&1
python3 tools/gate-summary.py "$VLOG" || die "gate not green on $SHA7; nothing pushed"
if [ "$PUSH" = 1 ]; then
  ancestry                            # again: a branch may have moved meanwhile
  push_all
fi
[ "$KEEP" = 1 ] || clear_build
