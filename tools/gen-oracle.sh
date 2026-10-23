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
# optional CTAID=<n> (ccv-sim -ctaid), an optional CTAS=<n>, an optional
# THREADS=<n> (ccv-sim -threads), an optional WARPS=<n> (the CTA's first n
# warps, each its own run with ccv-sim -warp: oracle.<w>.jsonl for warp w of
# the CTA; TI-29), an optional CONST=<base>:<limit> (F-RO's
# .const range, ccv-sim -const-range), an optional FAULT=<cause> (the run
# ends in that fault, ccv-sim's exit 3, its record and state at the fault
# written; TI-26, TI-28; with several warps, the first), then one poke per
# line. ccv-sim runs one
# warp a CTA, so a kernel of several warps is CTAS CTAs, CTAID upward, each
# its own run: oracle.jsonl for the first, oracle.<w>.jsonl for warp w, which
# the skeleton launches side by side (Kernel::loadOracles).
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
  # THREADS=<n>: a CTA of n threads (ccv-sim -threads), so a warp of fewer
  # than 32 launches with only its low lanes live (TI-27 (a)).
  threads=$(sed -n 's/^THREADS=//p' "$k/kernel.cfg")
  warps=$(sed -n 's/^WARPS=//p' "$k/kernel.cfg")
  crange=$(sed -n 's/^CONST=//p' "$k/kernel.cfg")
  fault=$(sed -n 's/^FAULT=//p' "$k/kernel.cfg")
  out=$O/$name
  rm -rf "$out" && mkdir -p "$out"
  ok=1
  python3 "$C/tools/ccv-as.py" "$C/build/generated/CCV.json" "$srcpath" \
    "$out/kernel.bin" >/dev/null || ok=0
  for ((w = 0; ok && w < ${ctas:-${warps:-1}}; ++w)); do
    o="$out/oracle.jsonl"; [ $w = 0 ] || o="$out/oracle.$w.jsonl"
    cta=()
    [ -n "$ctaid$ctas" ] && cta=(-ctaid $(( ${ctaid:-0} + w )))
    [ -n "$warps" ] && cta=(-ctaid "${ctaid:-0}" -warp "$w")
    # The hardware warp context srd #2 names (O-64): RAU gives run w's warp
    # warp_id w, so ccv-sim's %lanectx must name w too, whichever CTA and
    # warp of it the run is (ccv-sim -context, TI-35).
    cta+=(-context "$w")
    "$C/release/bin/ccv-sim" "$out/kernel.bin" "${args[@]}" "${cta[@]}" \
      ${threads:+-threads "$threads"} ${crange:+-const-range "$crange"} \
      -fairness="$fair" -oracle "$o" >/dev/null
    st=$?
    # A clean run exits 0, a fault 3: either must be the one kernel.cfg names.
    # A kernel of several warps faults in its first; the rest run clean, as
    # the runs the context's kill cuts short (V-24).
    if [ -n "$fault" ] && [ $w = 0 ]; then
      [ $st = 3 ] && grep -q "\"fault\":{\"cause\":\"$fault\"" "$o" || ok=0
    else
      [ $st = 0 ] || ok=0
    fi
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
