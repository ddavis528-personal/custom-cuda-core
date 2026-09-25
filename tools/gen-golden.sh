#!/usr/bin/env bash
# Golden oracle records for Stage 3 kernels, from ccv-sim -oracle.
#
# The skeleton takes WHAT each instruction does from ccv-sim and models WHEN
# (strategy §1). The record it consumes is checked in here, so the core repo
# runs without the compiler repo present; this script regenerates it and, with
# --check, says whether the checked-in copy has drifted from what the compiler
# repo's ccv-sim now produces.
#
#   tools/gen-golden.sh [--check]
#
# The compiler repo is found at $CCV_COMPILER_DIR, else ../custom-cuda-complier.
# Its build/ must hold ccv-sim and generated/CCV.json. --check with no compiler
# repo SKIPs rather than passing: a check that could not run has not passed.
set -uo pipefail
cd "$(dirname "$0")/.."
C=${CCV_COMPILER_DIR:-../custom-cuda-complier}
check=0; [ "${1:-}" = "--check" ] && check=1

if [ ! -x "$C/build/ccv-sim" ] || [ ! -f "$C/build/generated/CCV.json" ]; then
  echo "  golden oracle records                          SKIP -- no ccv-sim at $C/build"
  exit 0
fi

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
rc=0
for k in test/golden/*/; do
  k=${k%/}; name=$(basename "$k")
  [ -f "$k/kernel.cfg" ] || continue
  # kernel.cfg: SOURCE=<path in the compiler repo, or core:<path in this one>>,
# then one poke per line.
  src=$(sed -n 's/^SOURCE=//p' "$k/kernel.cfg")
  # core:<path> is relative to this repo; anything else to the compiler's.
  case "$src" in
    core:*) srcpath="$(pwd)/${src#core:}" ;;
    *)      srcpath="$C/$src" ;;
  esac
  pokes=()
  while read -r p; do pokes+=(-poke "$p"); done < <(grep -E '^0x' "$k/kernel.cfg")
  python3 "$C/tools/ccv-as.py" "$C/build/generated/CCV.json" "$srcpath" \
    "$tmp/$name.bin" >/dev/null || { echo "  $name: $src did not assemble"; rc=1; continue; }
  "$C/build/ccv-sim" "$tmp/$name.bin" "${pokes[@]}" -oracle "$tmp/$name.jsonl" \
    >/dev/null || { echo "  $name: ccv-sim -oracle failed"; rc=1; continue; }
  if [ $check = 1 ]; then
    if cmp -s "$tmp/$name.jsonl" "$k/oracle.jsonl"; then
      printf '  %-46s %s\n' "golden $name matches ccv-sim" "PASS"
    else
      printf '  %-46s %s\n' "golden $name matches ccv-sim" \
        "FAIL -- drifted; rerun tools/gen-golden.sh and review the diff"
      rc=1
    fi
  else
    cp "$tmp/$name.jsonl" "$k/oracle.jsonl"
    echo "  wrote $k/oracle.jsonl ($(wc -l < "$k/oracle.jsonl") records)"
  fi
done
exit $rc
