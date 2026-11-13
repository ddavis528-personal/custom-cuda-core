#!/usr/bin/env bash
# tools/detach.sh and tools/gate-wait.sh, on a stand-in for a long tool (a
# few seconds, exit 7). The claims, each with a control that must fail:
#   detaches     the tool returns at once, and its job survives its caller's
#                process group being killed (as a background task's limit
#                kills it); control: CCV_FOREGROUND=1, the same kill ends it
#   result       gate-wait returns the job's own exit status, 7
#   nested       inside a job (CCV_DETACHED set) the tool runs in place, as
#                gate-push.sh's own verify.sh does
#   waiting      gate-wait at its limit says so, exit 3
#   killed       a job gone with no exit status: gate-wait exit 4
# Prints one line per claim; exits 0 when every claim and control holds.
set -uo pipefail
R=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export CCV_LOGDIR="$T/logs" CCV_WAIT_POLL=1
unset CCV_DETACHED CCV_FOREGROUND CI GITHUB_ACTIONS
bad=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
fail() { say "$1" "FAIL -- $2"; bad=1; }

# The stand-in: sources the real detach.sh, as the entry points do.
cat >"$T/longtool.sh" <<EOF
#!/usr/bin/env bash
. "$R/tools/detach.sh"; ccv_detach "\$0" "\$@"
sleep "\${1:-3}"; exit 7
EOF
chmod +x "$T/longtool.sh"
joblog() { ls -t "$CCV_LOGDIR"/job-longtool-2*.log 2>/dev/null | head -1; }
# Alive: running, not a zombie (a container's init may never reap one).
alive() { local st; st=$(ps -o stat= -p "$1" 2>/dev/null) && [ -n "$st" ] && [ "${st:0:1}" != Z ]; }
jobpid() { sed -n 's/^CCV-JOB-PID \([0-9]*\) .*/\1/p' "$1" | head -1; }

# detaches: the caller in its own process group, killed whole once the tool
# returned; the job must live on.
t0=$(date +%s)
setsid bash -c "echo \$\$ >'$T/caller'; '$T/longtool.sh' 4 >'$T/out' 2>&1; sleep 30" &
for _ in $(seq 20); do [ -s "$T/out" ] && grep -q detached "$T/out" && break; sleep 0.5; done
sleep 1; log=$(joblog); pid=$([ -n "$log" ] && jobpid "$log")
kill -- -"$(cat "$T/caller")" 2>/dev/null; sleep 1
if grep -q 'detached as pid' "$T/out" && [ $(( $(date +%s) - t0 )) -lt 4 ] &&
   [ -n "$pid" ] && alive "$pid"; then
  say "detaches: returns at once, survives its caller" "PASS"
else
  fail "detaches" "out: $(head -c 200 "$T/out"); pid ${pid:-none}"
fi
# result: the job's own status through gate-wait.
"$R/tools/gate-wait.sh" "$log" >"$T/wait" 2>&1; rc=$?
if [ "$rc" = 7 ] && grep -q '^gate-wait: done: exit 7' "$T/wait"; then
  say "result: gate-wait returns the job's exit 7" "PASS"
else
  fail "result" "exit $rc: $(tail -1 "$T/wait")"
fi
# control: in the foreground, the same kill ends the tool.
rm -f "$T/out"
setsid bash -c "echo \$\$ >'$T/caller'; CCV_FOREGROUND=1 '$T/longtool.sh' 4 >'$T/out' 2>&1 & echo \$! >'$T/fg'; wait" &
sleep 1; fg=$(cat "$T/fg"); kill -- -"$(cat "$T/caller")" 2>/dev/null; sleep 1
if ! alive "$fg" && ! grep -q detached "$T/out" 2>/dev/null; then
  say "control foreground: the caller's kill ends it" "PASS (refused)"
else
  fail "control foreground" "it survived, or detached anyway"
fi
# nested: inside a job, in place: exit 7, no detach line.
out=$(CCV_DETACHED=1 "$T/longtool.sh" 1 2>&1); rc=$?
if [ "$rc" = 7 ] && ! grep -q detached <<<"$out"; then
  say "nested: runs in place inside a job" "PASS"
else
  fail "nested" "exit $rc: $out"
fi
# waiting: a longer job, a 1-second limit.
"$T/longtool.sh" 6 >/dev/null; sleep 1; log=$(joblog)
CCV_WAIT_MAX=1 "$R/tools/gate-wait.sh" "$log" >"$T/wait" 2>&1; rc=$?
if [ "$rc" = 3 ] && grep -q '^gate-wait: waiting' "$T/wait"; then
  say "waiting: at its limit, exit 3" "PASS"
else
  fail "waiting" "exit $rc: $(tail -1 "$T/wait")"
fi
# killed: that job, killed before its end.
kill "$(jobpid "$log")" 2>/dev/null; pkill -P "$(jobpid "$log")" 2>/dev/null; sleep 1
"$R/tools/gate-wait.sh" "$log" >"$T/wait" 2>&1; rc=$?
if [ "$rc" = 4 ] && grep -q '^gate-wait: killed' "$T/wait"; then
  say "killed: no exit status, exit 4" "PASS"
else
  fail "killed" "exit $rc: $(tail -1 "$T/wait")"
fi
exit $bad
