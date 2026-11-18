#!/usr/bin/env bash
# A long run, detached from the caller and logged to a file, ending in one
# line a session can read instead of tailing the log:
#
#   tools/bg-run.sh <name> <command...>
#
# The command runs in its own session (setsid nohup, tools/detach.sh's way),
# so neither a background task's 2-hour limit nor the caller's end kills it
# (DA, 2026-11-13). This script then waits for it as tools/gate-wait.sh does,
# for at most CCV_WAIT_MAX seconds (110 minutes), and prints
#   bg-run: <name> exit <n> in <s>s; log <path>; last: <last non-empty line>
# or, still running, "bg-run: <name> waiting ..." with exit 3: run
# tools/gate-wait.sh on the job log it names, again, until it is done. Run it
# as the session's background task, which keeps the container active too.
set -uo pipefail
[ $# -ge 2 ] || { echo "usage: $0 <name> <command...>" >&2; exit 2; }
name=$1; shift
LOGDIR=${CCV_LOGDIR:-$HOME/ccv-logs}; mkdir -p "$LOGDIR"
log="$LOGDIR/$name.log"
t0=$(date +%s)
CCV_DETACHED=1 setsid nohup bash -c '
  echo "CCV-JOB-PID $$ $(date -u +%s) $*"
  "$@"
  echo "CCV-JOB-EXIT $?"' ccv-job "$@" >"$log" 2>&1 </dev/null &
"$(dirname "$0")/gate-wait.sh" "$log" >/dev/null; rc=$?
last=$(grep -v -e '^[[:space:]]*$' -e '^CCV-JOB-' "$log" | tail -1 | cut -c1-200)
case $rc in
  3) echo "bg-run: $name waiting after $(( $(date +%s) - t0 ))s; run tools/gate-wait.sh $log; last: $last" ;;
  4) echo "bg-run: $name killed (no exit status; a restart?); log $log; last: $last" ;;
  *) echo "bg-run: $name exit $rc in $(( $(date +%s) - t0 ))s; log $log; last: $last" ;;
esac
exit $rc
