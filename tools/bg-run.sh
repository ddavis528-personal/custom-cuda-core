#!/usr/bin/env bash
# A long run, logged to a file, ending in one line a session can read instead
# of tailing the log:
#
#   tools/bg-run.sh <name> <command...>
#
# Writes $CCV_LOGDIR/<name>.log and prints
#   bg-run: <name> exit <n> in <s>s; log <path>; last: <last non-empty line>
# Pair it with the session's background runner, which reports the exit.
set -uo pipefail
[ $# -ge 2 ] || { echo "usage: $0 <name> <command...>" >&2; exit 2; }
name=$1; shift
LOGDIR=${CCV_LOGDIR:-$HOME/ccv-logs}; mkdir -p "$LOGDIR"
log="$LOGDIR/$name.log"
t0=$(date +%s)
"$@" >"$log" 2>&1; rc=$?
last=$(grep -v '^[[:space:]]*$' "$log" | tail -1 | cut -c1-200)
echo "bg-run: $name exit $rc in $(( $(date +%s) - t0 ))s; log $log; last: $last"
exit $rc
