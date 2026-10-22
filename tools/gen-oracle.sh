#!/usr/bin/env bash
# Every S1 kernel's oracle record, generated from the pinned compiler snapshot.
#
# The skeleton takes WHAT each instruction does from ccv-sim and models WHEN
# (strategy §1). The records are not checked in: each gate run assembles
# test/kernels/<k>/ with the snapshot's tools/ccv-as.py and CCV.json and runs
# its built ccv-sim -oracle, writing build/oracle/<k>/oracle.jsonl. The
# snapshot is pinned (tools/compiler.lock), so a compiler change reaches this
# gate only through a reviewed bump -- which is what checking the records in
# used to buy, without the second copy that could drift.
#
# kernel.cfg: SOURCE=<path in the compiler snapshot, or core:<path here>>, an
# optional CTAID=<n> (ccv-sim -ctaid), an optional CTAS=<n>, then one poke per
# line. ccv-sim runs one warp a CTA, so a kernel of several warps is CTAS
# CTAs, CTAID upward, each its own run: oracle.jsonl for the first,
# oracle.<w>.jsonl for warp w, which the skeleton launches side by side
# (Kernel::loadOracles).
set -uo pipefail
cd "$(dirname "$0")/.."
C=$(tools/fetch-compiler.sh) || exit 1
O=${CCV_ORACLE_DIR:-build/oracle}   # the N sweep's records go elsewhere (below)
rc=0
# A kernel removed from test/kernels/ leaves no record behind: the checks
# that run every record (ls build/oracle) would go on running it.
for d in "$O"/*/; do
  [ -d "$d" ] && [ ! -d "test/kernels/$(basename "$d")" ] && rm -rf "$d"
done
# The diverged groups' pick is FET's fairness rule at CCV_FAIR_N (IS-17,
# O-60), ccv-sim's -fairness, so the order the skeleton follows is the one
# FET would pick.
# CCV_FAIR_N in the environment overrides it, for the N sweep
# (tools/sweep-fair.sh), which runs the skeleton's FET at the same N and
# writes the records to CCV_ORACLE_DIR rather than build/oracle.
fair=${CCV_FAIR_N:-$(sed -n 's/.*kFairN = \([0-9]*\);.*/\1/p' sim/generated/ccv_params.h)}
[ -n "$fair" ] || { echo "gen-oracle: no CCV_FAIR_N in sim/generated/ccv_params.h" >&2; exit 1; }
for k in test/kernels/*/; do
  k=${k%/}; name=$(basename "$k")
  [ -f "$k/kernel.cfg" ] || continue
  src=$(sed -n 's/^SOURCE=//p' "$k/kernel.cfg")
  case "$src" in
    core:*) srcpath="${src#core:}" ;;
    *)      srcpath="$C/$src" ;;
  esac
  args=()
  while read -r p; do args+=(-poke "$p"); done < <(grep -E '^0x' "$k/kernel.cfg")
  ctaid=$(sed -n 's/^CTAID=//p' "$k/kernel.cfg")
  ctas=$(sed -n 's/^CTAS=//p' "$k/kernel.cfg")
  out=$O/$name
  rm -rf "$out" && mkdir -p "$out"
  ok=1
  python3 "$C/tools/ccv-as.py" "$C/build/generated/CCV.json" "$srcpath" \
    "$out/kernel.bin" >/dev/null || ok=0
  for ((w = 0; ok && w < ${ctas:-1}; ++w)); do
    o="$out/oracle.jsonl"; [ $w = 0 ] || o="$out/oracle.$w.jsonl"
    cta=()
    [ -n "$ctaid$ctas" ] && cta=(-ctaid $(( ${ctaid:-0} + w )))
    "$C/release/bin/ccv-sim" "$out/kernel.bin" "${args[@]}" "${cta[@]}" \
      -fairness="$fair" -oracle "$o" >/dev/null || ok=0
  done
  if [ $ok = 1 ]; then
    printf '  %-46s %s\n' "oracle $name from the pinned ccv-sim" \
      "PASS ($(cat "$out"/oracle*.jsonl | wc -l) records${ctas:+, $ctas warps})"
  else
    printf '  %-46s %s\n' "oracle $name from the pinned ccv-sim" "FAIL"
    rc=1
  fi
done
exit $rc
