#!/usr/bin/env bash
# MA's Phase 1 sweep runner (MA-21): every kernel whose oracle is in ORACLE_DIR
# through build/skel/ccv-skel under the environment it is given, one TSV row
# a kernel: name, finished, cycles, check_failures, l1_hit, l1_late, l1_inelig,
# then the P1 line's measures as key=value (CCV_DCU_IMPL=p1 only).
#
#   sim/dcu/p1-run.sh <oracle dir> <out.tsv> [KEY=VALUE ...]
#   e.g. sim/dcu/p1-run.sh build/p1/o build/p1/a.tsv CCV_DCU_IMPL=p1 CCV_P1_STORE=a
#
# Not part of the gate. Runs nproc kernels at a time; a kernel's log is kept
# beside the TSV (<out>.d/<kernel>.log).
set -uo pipefail
cd "$(dirname "$0")/../.."
od=$1; out=$2; shift 2
SKEL=build/skel/ccv-skel
[ -x "$SKEL" ] || { echo "p1-run: no $SKEL (tools/check-skel.sh builds it)" >&2; exit 1; }
d="$out.d"; mkdir -p "$d"
export SKEL d
for kv in "$@"; do export "$kv"; done
one() {
  k=$1; dir=$2
  "$SKEL" --kernel "$dir/$k/oracle.jsonl" >"$d/$k.log" 2>&1
  f() { sed -n 's/^KERNEL .*/&/p' "$d/$k.log" | tr ' ' '\n' | sed -n "s/^$1=//p" | head -1; }
  c() { sed -n 's/^COVER //p' "$d/$k.log" | tr ' ' '\n' | sed -n "s/^$1=//p" | head -1; }
  p1=$(sed -n 's/^P1 //p' "$d/$k.log" | tr ' ' '\t')
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$k" "$(f finished)" "$(f cycles)" \
    "$(f check_failures)" "$(c l1_hit)" "$(c l1_late)" "$(c l1_inelig)" "$p1"
}
export -f one
ls "$od" | while read -r k; do [ -f "$od/$k/oracle.jsonl" ] && echo "$k"; done |
  xargs -P "$(nproc)" -I{} bash -c 'one "$1" "$2"' _ {} "$od" | sort >"$out"
echo "p1-run: $(wc -l <"$out") kernels -> $out"
