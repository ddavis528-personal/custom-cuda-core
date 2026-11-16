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
# --import=a.tgz[,b.tgz] (OI-101; DA, 2026-11-01): a gate split across
# containers. Each file is another container's tools/gate-export.sh of the
# same commit: its passed sections are skipped here, and the joined gate
# passes only if tools/gate-combine.py finds one commit and tree, and every
# section the scope needs passed exactly once (SPLIT PASS / SPLIT SCOPED
# PASS). A file's build/synth-cache, if it carries one, merges into ours
# first (content-keyed entries; ours win on a clash).
#
# Prints a few lines: regen's commit if any, the gate's summary
# (tools/gate-summary.py), what it pushed. Logs go to $CCV_LOGDIR. Exit 1 on
# any refusal or a red gate, with nothing pushed; a red gate's job logs are
# kept in $CCV_LOGDIR and build/ cleared all the same (but --keep-build).
set -uo pipefail
cd "$(dirname "$0")/.."
ME=gate-push
. tools/push-lib.sh
PUSH=1 KEEP=0 FULLGATE=0 IMPORTS=""
for a in "$@"; do
  case "$a" in
    --branches=*) CCV_PUSH_BRANCHES=${a#--branches=} ;;
    --no-push)    PUSH=0 ;;
    --keep-build) KEEP=1 ;;
    --full)       FULLGATE=1 ;;
    --import=*)   IMPORTS=$(echo "${a#--import=}" | tr ',' ' ') ;;
    *) echo "usage: $0 [--branches=a,b] [--no-push] [--keep-build] [--full] [--import=a.tgz,..]" >&2; exit 2 ;;
  esac
done
# A long run never runs under its caller (tools/detach.sh; DA, 2026-11-13):
# it detaches and returns; tools/gate-wait.sh waits for it.
. "$(dirname "$0")/detach.sh"; ccv_detach "$0" "$@"

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
IMP_DIRS=() IMP_SKIP=""
n=0
for f in $IMPORTS; do
  n=$((n + 1))
  d="$LOGDIR/import-$SHA7-$STAMP-$n"
  mkdir -p "$d" && tar -xzf "$f" -C "$d" || die "cannot unpack $f"
  if [ -d "$d/build/synth-cache" ]; then
    mkdir -p build/synth-cache && cp -rn "$d/build/synth-cache/." build/synth-cache/
    say "merged $f's synthesis cache"
  fi
  [ -f "$d/build/verify/manifest.json" ] || continue
  c=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["commit"])' "$d/build/verify/manifest.json")
  [ "$c" = "$PUSH_SHA" ] || die "$f ran ${c:0:7}, not $SHA7 (regen moved HEAD? gate $SHA7 there)"
  ran=$(python3 -c 'import json,sys; print(",".join(j for j,v in json.load(open(sys.argv[1]))["sections"].items() if v["outcome"]=="pass"))' "$d/build/verify/manifest.json")
  [ -n "$ran" ] && IMP_SKIP="${IMP_SKIP:+$IMP_SKIP,}$ran"
  IMP_DIRS+=("$d/build/verify")
  say "imported $f: ${ran:-no passed section}"
done
[ -n "$IMP_SKIP" ] && GATE_ARGS+=(--skip "$IMP_SKIP")
say "gate on $SHA7 (log: $VLOG)"
./tools/verify.sh "${GATE_ARGS[@]}" >"$VLOG" 2>&1
gate_ok() {
  if [ ${#IMP_DIRS[@]} -gt 0 ]; then
    # Here a PARTIAL PASS, half of the gate; the join decides.
    local sum; sum=$(python3 tools/gate-summary.py "$VLOG")
    echo "$sum"
    case "$sum" in "gate: PARTIAL PASS"*) ;; *) return 1 ;; esac
    python3 tools/gate-combine.py build/verify "${IMP_DIRS[@]}"
  else
    python3 tools/gate-summary.py "${SUM_ARGS[@]}" "$VLOG"
  fi
}
if ! gate_ok; then
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
