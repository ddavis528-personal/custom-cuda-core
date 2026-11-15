# Sourced by the long entry points (verify.sh, gate-push.sh, daily-sweep.sh,
# make-release.sh, bg-run.sh); never run. Their first act:
#
#   . "$(dirname "$0")/detach.sh"; ccv_detach "$0" "$@"
#
# A gate runs 1-2.5 hours. A session's background task is killed at 2
# hours, and a container left idle is reclaimed, with whatever it runs:
# gates were lost both ways, again and again (DA, 2026-11-13). So a long
# entry point never runs under the caller: it re-launches itself in its own
# session (setsid nohup), writes its log, prints its pid and log and how to
# wait, and returns at once with status 5, never 0: a caller that tests it
# must not read "detached" as "passed". A daily sweep begun from a tree
# before the detach called the new make-release.sh, took its 0 for a green
# gate and pushed a merge ungated (OA-414, 2026-11-14). 5 is no tool's
# result: 1 is red, 3 a conflict or gate-wait's "still running", 4 its
# "killed". The job's own exit status is the last line of its log
# ("CCV-JOB-EXIT <n>"), which tools/gate-wait.sh reads.
#
# Stays in the foreground: a call from another such tool (CCV_DETACHED is
# set in the job's environment, so gate-push.sh's own verify.sh runs inside
# it), CI (CI or GITHUB_ACTIONS set), and CCV_FOREGROUND=1.

ccv_detach() {
  if [ -n "${CCV_DETACHED:-}" ] || [ -n "${CCV_FOREGROUND:-}" ] ||
     [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
    return 0
  fi
  local name logdir log pid
  name=$(basename "$1" .sh)
  logdir=${CCV_LOGDIR:-$HOME/ccv-logs}
  mkdir -p "$logdir"
  log="$logdir/job-$name-$(date -u +%Y%m%d-%H%M%S)-$$.log"
  # The job: the same command, in its own session, its exit status logged.
  CCV_DETACHED=1 setsid nohup bash -c '
    echo "CCV-JOB-PID $$ $(date -u +%s) $*"
    "$@"
    echo "CCV-JOB-EXIT $?"' ccv-job "$@" >"$log" 2>&1 </dev/null &
  pid=$!
  ln -sfn "$log" "$logdir/job-$name-latest.log"
  echo "$name: detached as pid $pid; log $log"
  echo "$name: wait with tools/gate-wait.sh $log, as a background task: it returns the"
  echo "$name: job's result, or 'still running' before 2 hours; then run it again."
  echo "$name: exit 5 means detached, not passed"
  exit 5
}
