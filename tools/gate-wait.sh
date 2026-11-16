#!/usr/bin/env bash
# Wait for a detached job (tools/detach.sh), for at most CCV_WAIT_MAX seconds
# (default 6600, 110 minutes: inside a background task's 2-hour limit).
#
#   tools/gate-wait.sh [<job log>]     default: the newest job log
#
# Run it as the session's background task. While it waits, the session is
# active, so its container is not reclaimed idle under the job (DA,
# 2026-11-13). It ends in one line and an exit status:
#   done     the job ended: its last lines, a gate's summary if its log names
#            one, and the job's own exit status
#   waiting  still running at CCV_WAIT_MAX: exit 3. Run this again, at once.
#   killed   the job is gone with no exit status (a container restart): exit
#            4. Start the job again.
set -uo pipefail
LOGDIR=${CCV_LOGDIR:-$HOME/ccv-logs}
log=${1:-$(ls -t "$LOGDIR"/job-*-2*.log 2>/dev/null | head -1)}
[ -n "$log" ] && [ -f "$log" ] || { echo "gate-wait: no job log ${1:-in $LOGDIR}" >&2; exit 2; }
max=${CCV_WAIT_MAX:-6600}
pid=$(sed -n 's/^CCV-JOB-PID \([0-9]*\) .*/\1/p' "$log" | head -1)
t0=$(date +%s)
ended() { grep -q '^CCV-JOB-EXIT ' "$log"; }
# Alive: running, not a zombie (a container's init may never reap one).
alive() { local st; st=$(ps -o stat= -p "$1" 2>/dev/null) && [ -n "$st" ] && [ "${st:0:1}" != Z ]; }
# The pid line is written as the job starts; give it a moment.
for _ in 1 2 3 4 5; do [ -n "$pid" ] && break; sleep 1
  pid=$(sed -n 's/^CCV-JOB-PID \([0-9]*\) .*/\1/p' "$log" | head -1); done
while ! ended; do
  if [ -z "$pid" ] || ! alive "$pid"; then
    ended && break
    echo "gate-wait: killed: pid ${pid:-?} is gone with no exit status (a restart?); log $log"
    exit 4
  fi
  if [ $(( $(date +%s) - t0 )) -ge "$max" ]; then
    echo "gate-wait: waiting: pid $pid still running after $(( ($(date +%s) - t0) / 60 )) min; run tools/gate-wait.sh $log again"
    exit 3
  fi
  sleep "${CCV_WAIT_POLL:-30}"
done
rc=$(sed -n 's/^CCV-JOB-EXIT \([0-9]*\)$/\1/p' "$log" | tail -1)
grep -v -e '^[[:space:]]*$' -e '^CCV-JOB-' "$log" | tail -6
# A gate's own log, if the job names one: its summary, not the log. Only
# a verify-*.log is a gate's: a release-*.log is make-release's, whose gate
# log is elsewhere and which says its own verdict (it read NO RESULT here).
glog=$(grep -o '/[^ ]*ccv-logs/verify-[^ )]*\.log' "$log" | tail -1)
[ -n "$glog" ] && [ -f "$glog" ] && [ -x "$(dirname "$0")/gate-summary.py" ] &&
  python3 "$(dirname "$0")/gate-summary.py" "$glog" 2>/dev/null | head -3
echo "gate-wait: done: exit $rc; log $log"
exit "${rc:-1}"
