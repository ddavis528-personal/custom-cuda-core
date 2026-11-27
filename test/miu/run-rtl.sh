#!/usr/bin/env bash
# MI's MIU RTL benches under Verilator, assertions on (docs/miu-impl.md; MA's
# Phase 2, MIU tab rev 147): each module against its value model, at the
# sizes its units use. One PASS line each; any failure fails the run.
#   miu_cap: test/miu/cap_tb.cpp, one address slot's capture, and its
#            control early (the payload taken with its valid), which must fail
#   miu_pair: test/miu/pair_tb.cpp, each address paired with its memop by
#            arrival cycle and lead pipe, and its controls arrival (paired on
#            the arrival slot) and lag (a cycle late), each of which must fail
#   miu_mq: test/miu/mq_tb.cpp, the memop queue and its lane map, controls slot, discard,
#     ilv (an interleaved lane's word as its sum's) and local (a local lane's byte as its sum's)
#   miu_agu8: test/miu/agu8_tb.cpp, one lane octet's A1 sums and F-ALIGN,
#            O-83's decision (MI-25 (D)), controls xfer (O-80's size ignored),
#            sext (disp unsigned), lane0 (lane d taken as 0), noshift (b
#            from the sum without rbase << 16) and wnoc (the window compare
#            without the carry into bit 16 + k); miu_agu8_lc the same at LC = 1,
#            lane 0's line copied for miu_grp (MA rev 209), control lcl1 (lane
#            1's line taken)
#   miu_rcap: test/miu/rcap_tb.cpp, one ccv_dcu_miu_rsp slot's capture,
#   miu_hitq: test/miu/hitq_tb.cpp, the first-pass delay line (lookup slot to
#     MQ entry and address slot, H+1 to R1); controls nodrop (A2's drop
#     ignored) and early (R1 a cycle early),
#   miu_lead: test/miu/lead_tb.cpp, A1 leaders, set index and the every-bank
#     gate (MI-27 (b)); controls used (a gate blind to last cycle's
#     launches), scale (no index scale) and lowest (the lowest active lane,
#     not the fixed leader),
#   miu_a2: test/miu/a2_tb.cpp, A2's lookup, PA and drop, controls carry,
#     bank, addr, line, split, fone, win (an ordinary lane in the run's
#     windows), iblk (an interleaved lane off W's block) and align,
#   miu_tlb: test/miu/tlb_tb.cpp, each slot's L0 and the 32-entry TLB's
#     refill (MA revs 199, 206-208), controls early (the L0 written a cycle
#     early), norr (the grant to the lowest pending slot), tight (the
#     refill bound one cycle short), l0dup (no second-miss filter), wvkeep
#     (an invalidate leaves the last-write copy) and ivkeep (it leaves the
#     refills in flight),
#   miu_ids: test/miu/ids_tb.cpp, the DCU req_ids: quarter picks, releases
#     and the id-to-entry table,
#   miu_cred: test/miu/cred_tb.cpp, DCU bank credits and the A1 gate,
#            controls early (a return counted as it lands) and norefund
#   miu_form: test/miu/form_tb.cpp, the slot, local and private forms'
#            state and H flops (MI-21, MI-23 (b)), controls lane0 (lane d
#            taken as 0), nohi1 (R(ctx)'s hi + 1 not kept), noctx and cflat
#            (O-69's C with b not rearranged)
set -uo pipefail
cd "$(dirname "$0")/../.."
B=build/miu-rtl; mkdir -p "$B"
fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
bench() {   # name, build command..., then the run's argv after --
  local name=$1; shift
  local build=() run=()
  while [ "$1" != -- ]; do build+=("$1"); shift; done; shift; run=("$@")
  if ! "${build[@]}" >"$B/$name.build.log" 2>&1; then
    say "$name" "FAIL (build; $B/$name.build.log)"; fail=1; return
  fi
  if "${run[@]}" >"$B/$name.log" 2>&1 && grep -q ": PASS$" "$B/$name.log"; then
    say "$name" "PASS ($(grep -o '[0-9]* values checked' "$B/$name.log" | head -1))"
  else
    say "$name" "FAIL ($B/$name.log)"; tail -5 "$B/$name.log" | sed 's/^/    /'; fail=1
  fi
}
control() {   # unit, control: the bench must fail with mismatches
  local u=$1 c=$2
  if [ -x "$B/$u/tb" ] && ! "$B/$u/tb" --control "$c" >"$B/$u.$c.log" 2>&1 &&
     grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/$u.$c.log"; then
    say "$u control $c" "caught"
  else
    say "$u control $c" "NOT CAUGHT ($B/$u.$c.log)"; fail=1
  fi
}
bench miu_cap test/miu/cg-build.sh miu_cap "$B/miu_cap" -- "$B/miu_cap/tb"
control miu_cap early
bench miu_pair test/miu/cg-build.sh miu_pair "$B/miu_pair" -- "$B/miu_pair/tb"
control miu_pair arrival
control miu_pair lag
bench miu_mq test/miu/cg-build.sh miu_mq "$B/miu_mq" -- "$B/miu_mq/tb"
control miu_mq slot
control miu_mq discard
control miu_mq ilv
control miu_mq local
bench miu_agu8 test/miu/cg-build.sh miu_agu8 "$B/miu_agu8" -- "$B/miu_agu8/tb"
control miu_agu8 xfer
control miu_agu8 sext
control miu_agu8 lane0
control miu_agu8 noshift
control miu_agu8 wnoc
bench miu_agu8_lc test/miu/cg-build.sh miu_agu8_lc "$B/miu_agu8_lc" -- "$B/miu_agu8_lc/tb"
control miu_agu8_lc lcl1
bench miu_cred test/miu/cg-build.sh miu_cred "$B/miu_cred" -- "$B/miu_cred/tb"
control miu_cred early
control miu_cred norefund
bench miu_form test/miu/cg-build.sh miu_form "$B/miu_form" -- "$B/miu_form/tb"
control miu_form lane0
control miu_form nohi1
control miu_form noctx
control miu_form cflat
bench miu_ids test/miu/cg-build.sh miu_ids "$B/miu_ids" -- "$B/miu_ids/tb"
control miu_ids noskip
control miu_ids relnow
control miu_ids nodrop
bench miu_rcap test/miu/cg-build.sh miu_rcap "$B/miu_rcap" -- "$B/miu_rcap/tb"
control miu_rcap early
bench miu_hitq test/miu/cg-build.sh miu_hitq "$B/miu_hitq" -- "$B/miu_hitq/tb"
control miu_hitq nodrop
control miu_hitq early
bench miu_lead test/miu/cg-build.sh miu_lead "$B/miu_lead" -- "$B/miu_lead/tb"
control miu_lead used
control miu_lead scale
control miu_lead lowest
bench miu_tlb test/miu/cg-build.sh miu_tlb "$B/miu_tlb" -- "$B/miu_tlb/tb"
control miu_tlb early
control miu_tlb norr
control miu_tlb tight
control miu_tlb l0dup
control miu_tlb wvkeep
control miu_tlb ivkeep
bench miu_a2 test/miu/cg-build.sh miu_a2 "$B/miu_a2" -- "$B/miu_a2/tb"
control miu_a2 carry
control miu_a2 bank
control miu_a2 addr
control miu_a2 line
control miu_a2 split
control miu_a2 fone
control miu_a2 win
control miu_a2 iblk
control miu_a2 align
exit $fail
