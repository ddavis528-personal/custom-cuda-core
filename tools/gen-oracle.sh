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
# optional CTAID=<n> (ccv-sim -ctaid), then one poke per line.
set -uo pipefail
cd "$(dirname "$0")/.."
C=$(tools/fetch-compiler.sh) || exit 1
rc=0
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
  [ -n "$ctaid" ] && args+=(-ctaid "$ctaid")
  out=build/oracle/$name
  mkdir -p "$out"
  if python3 "$C/tools/ccv-as.py" "$C/build/generated/CCV.json" "$srcpath" \
       "$out/kernel.bin" >/dev/null &&
     "$C/release/bin/ccv-sim" "$out/kernel.bin" "${args[@]}" \
       -oracle "$out/oracle.jsonl" >/dev/null; then
    printf '  %-46s %s\n' "oracle $name from the pinned ccv-sim" \
      "PASS ($(wc -l < "$out/oracle.jsonl") records)"
  else
    printf '  %-46s %s\n' "oracle $name from the pinned ccv-sim" "FAIL"
    rc=1
  fi
done
exit $rc
