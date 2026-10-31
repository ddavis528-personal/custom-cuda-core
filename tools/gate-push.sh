#!/usr/bin/env bash
# Regen, commit, the gate, an ancestry check, push, clear build: one
# command for the routine every push takes (CLAUDE.md, The gate).
#
#   tools/gate-push.sh [--branches=a,b] [--no-push] [--keep-build] [--full]
#
# A push to a working branch takes the scoped gate (OI-95; DA, 2026-10-31):
# verify.sh --changed against the newest commit every target branch already
# holds, reusing build/synth-cache, which clearing build/ keeps. --full is
# the clean gate, every section and every netlist; the daily sweep's merge
# and every release take it whatever is asked here.
#
# Prints a few lines: regen's commit if any, the gate's summary
# (tools/gate-summary.py), what it pushed. Logs go to $CCV_LOGDIR. Exit 1 on
# any refusal or a red gate, with nothing pushed; a red gate's job logs are
# kept in $CCV_LOGDIR and build/ cleared all the same (but --keep-build).
set -uo pipefail
cd "$(dirname "$0")/.."
ME=gate-push
. tools/push-lib.sh
PUSH=1 KEEP=0 FULLGATE=0
for a in "$@"; do
  case "$a" in
    --branches=*) CCV_PUSH_BRANCHES=${a#--branches=} ;;
    --no-push)    PUSH=0 ;;
    --keep-build) KEEP=1 ;;
    --full)       FULLGATE=1 ;;
    *) echo "usage: $0 [--branches=a,b] [--no-push] [--keep-build] [--full]" >&2; exit 2 ;;
  esac
done
clean_tree
[ "$PUSH" = 1 ] && ancestry           # fail before the gate, not after it
regen_commit
PUSH_SHA=$(git rev-parse HEAD)
SHA7=$(git rev-parse --short HEAD)
VLOG="$LOGDIR/verify-$SHA7-$STAMP.log"
GATE_ARGS=() SUM_ARGS=()
if [ "$FULLGATE" != 1 ] && [ "$PUSH" = 1 ]; then
  # The scope's base: the newest commit on every target branch.
  refs=()
  for b in $(echo "$CCV_PUSH_BRANCHES" | tr ',' ' '); do
    git rev-parse -q --verify "origin/$b" >/dev/null && refs+=("origin/$b")
  done
  base=""
  [ ${#refs[@]} -gt 0 ] && base=$(git merge-base --octopus "${refs[@]}" 2>/dev/null)
  if [ -n "$base" ]; then
    GATE_ARGS=(--changed "$base") SUM_ARGS=(--scoped)
    say "scoped gate: the change since $(git rev-parse --short "$base")"
  else
    say "no base on the target branches: the full gate"
  fi
fi
say "gate on $SHA7 (log: $VLOG)"
./tools/verify.sh "${GATE_ARGS[@]}" >"$VLOG" 2>&1
if ! python3 tools/gate-summary.py "${SUM_ARGS[@]}" "$VLOG"; then
  # A red gate leaves ~16 GB in build/, more than the next gate can spare
  # (2026-10-31): keep its job logs beside the gate's log, then clear.
  if [ "$KEEP" != 1 ]; then
    [ -d build/verify ] && cp -r build/verify "$LOGDIR/verify-$SHA7-$STAMP.d"
    clear_build
    say "job logs kept in $LOGDIR/verify-$SHA7-$STAMP.d"
  fi
  die "gate not green on $SHA7; nothing pushed"
fi
if [ "$PUSH" = 1 ]; then
  ancestry                            # again: a branch may have moved meanwhile
  push_all
fi
[ "$KEEP" = 1 ] || clear_build
