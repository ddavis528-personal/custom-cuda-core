#!/usr/bin/env bash
# Time the benchmark kernels of test/bench/ on the skeleton (AR-20, AR-24):
# each with today's FET stub and with perfect fetch (CCV_FET_PERFECT=1), the
# gap between them being what branch prediction, return-address prediction
# (PF-36) and the checkpoints (PF-17) are worth.
#
# Usage: tools/time-bench.sh [test/bench/<k> ...]   (default: every one)
# Not part of the gate: CoreMark-derived's records are 300 MB a warp and a
# run takes many minutes. Records go to build/bench-oracle/<k>/, each run's
# log to build/bench/<k>.<fet>.log, and the table to stdout. CCV_BENCH_FET
# picks one front end (stub or perfect); CCV_BENCH_CYCLES bounds a run.
#
# Per run: cycles from the first fetch (AR-19); issue groups and their rate
# per warp, against the 2 a warp may issue; the warp-cycles fetch stalled
# with every checkpoint live; redirects and the warp-cycles fetch waited on
# them; rets and calls; DCU lookups and those for frames (AR-23); and the
# warp-cycles loads waited behind an older store of their warp (PF-42).
# Before the runs, every chwidth is held to a converged warp (F-197).
# The MLC stub sends every L1 miss to EXB, so memory latency is a cold bound.
set -uo pipefail
cd "$(dirname "$0")/.."
SKEL=build/skel/ccv-skel
[ -x "$SKEL" ] || tools/check-skel.sh >/dev/null || { echo "time-bench: no $SKEL" >&2; exit 1; }
if [ $# -gt 0 ]; then benches=("$@"); else benches=(test/bench/*/); fi
benches=("${benches[@]%/}")
CCV_ORACLE_DIR=build/bench-oracle tools/gen-oracle.sh "${benches[@]}" || exit 1
# Every chwidth in a converged warp (F-197), and its control: one with a lane
# cleared must be caught. The gate's kernels execute none yet.
for b in "${benches[@]}"; do
  o=(build/bench-oracle/"$(basename "$b")"/oracle*.jsonl)
  tools/check-chwidth-converged.py "${o[@]}" || exit 1
  tools/check-chwidth-converged.py --selftest "${o[@]}" || exit 1
done
mkdir -p build/bench
fets=(stub perfect)
[ -n "${CCV_BENCH_FET:-}" ] && fets=("$CCV_BENCH_FET")
val() { sed -n "s/.* $2=\\([0-9]*\\).*/\\1/p" <<<"$1"; }
printf '%-12s %-7s %10s %9s %5s %6s %9s %8s %10s %5s %5s %8s %8s %9s %s\n' kernel fet cycles groups warps \
  ipc/w ckpt_full redirect redir_wait ret call dcu frame ld_held result
rc=0
for b in "${benches[@]}"; do
  k=$(basename "$b")
  orc=build/bench-oracle/$k/oracle.jsonl
  warps=$(ls build/bench-oracle/"$k"/oracle*.jsonl | wc -l)
  for f in "${fets[@]}"; do
    log=build/bench/$k.$f.log
    CCV_FET_PERFECT=$([ "$f" = perfect ] && echo 1 || echo 0) \
      "$SKEL" --kernel "$orc" --cycles "${CCV_BENCH_CYCLES:-2000000000}" >"$log" 2>&1
    kl=$(grep '^KERNEL' "$log"); pl=$(grep '^PERF' "$log")
    cyc=$(val "$kl" from_fetch); grp=$(val "$kl" issue_groups)
    ok=FAIL
    [ "$(val "$kl" finished)" = 1 ] && [ "$(val "$kl" check_failures)" = 0 ] &&
      [ "$(val "$kl" gpr_mismatch)" = 0 ] && [ "$(val "$kl" mem_mismatch)" = 0 ] &&
      grep -q 'order=ok' <<<"$kl" && ok=PASS
    [ $ok = PASS ] || rc=1
    ipc=$(awk -v g="$grp" -v c="$cyc" -v w="$warps" 'BEGIN { printf c ? "%.3f" : "-", g / c / w }')
    printf '%-12s %-7s %10s %9s %5s %6s %9s %8s %10s %5s %5s %8s %8s %9s %s\n' "$k" "$f" "$cyc" "$grp" "$warps" \
      "$ipc" "$(val "$pl" ckpt_full)" "$(val "$pl" redirect)" "$(val "$pl" redirect_wait)" \
      "$(val "$pl" ret)" "$(val "$pl" call)" "$(val "$pl" dcu_lookups)" "$(val "$pl" frame_lookups)" \
      "$(val "$pl" st_ld_wait)" "$ok"
  done
done
exit $rc
