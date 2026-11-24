#!/usr/bin/env bash
# Stage 1d exit criteria (§8):
#
#   "style guide written (§9); lint rules FAIL a deliberately non-compliant
#    sample module -- demonstrated to bite, not merely configured;
#    shared-parameter generation produces matching C++ and RTL definitions
#    from one source"
#
# The middle criterion is checked per RULE, not in aggregate. A fixture that
# trips eight of eleven rules still "fails lint", and the three that went quiet
# would not be noticed until a block relied on one of them.
set -uo pipefail
cd "$(dirname "$0")/.."

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

# -- the style guide exists and documents every rule -----------------------
GUIDE=docs/rtl-coding-style.md
if [ -f "$GUIDE" ]; then
  say "style guide present" "PASS"
else
  bad "style guide present" "$GUIDE missing"
fi

# -- lint bites, rule by rule ---------------------------------------------
# Both fixtures, and CCV-L12 pointed at the fixture schema -- it is a
# cross-file rule keyed on schema/interfaces.json, so it cannot be
# counter-exampled by a .sv file alone.
python3 tools/lint-rtl.py rtl/lint/bad_module.sv >"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py --schema=rtl/lint/bad_interfaces.json \
  rtl/lint/bad_if_checker.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_xprop.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_naming.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_feedback.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_table.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_table2.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_table3.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_conn.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_conn2.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_tport.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_conn3.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_module_names.sv >"$TMP/names.log" 2>&1
python3 tools/lint-rtl.py --blocks=rtl/lint/bad_blocks.json \
  rtl/lint/ccv_reference.sv >>"$TMP/names.log" 2>&1
# The generated design (rtl/top, rtl/generated) is outside the per-file walk,
# so its names are checked by a pass of their own. Its counter-example: the
# real top under the name it had before OI-37.
mkdir -p "$TMP/gen"
sed 's/^module ccv_top /module ccv_core_top /' rtl/top/ccv_top.sv >"$TMP/gen/ccv_core_top.sv"
python3 tools/lint-rtl.py --names="$TMP/gen" rtl/lint/ccv_reference.sv >>"$TMP/names.log" 2>&1
cat "$TMP/names.log" >>"$TMP/bad.log"
if grep -q "CCV-L" "$TMP/bad.log"; then false; else true; fi
if [ $? -eq 0 ]; then
  bad "lint fails the non-compliant sample" "it passed"
else
  say "lint fails the non-compliant sample" "PASS"
fi

# Every rule the linter defines must be demonstrated by the fixture. Deriving
# the expected list from the source rather than hardcoding it means a new rule
# added without a counter-example fails here, instead of shipping unexercised.
# Both construction forms: add("CCV-Lnn", ...) for per-file rules and
# Finding("CCV-Lnn", ...) for the cross-file ones. Matching only the first
# silently excused CCV-L12 from ever being verified.
RULES=$(grep -oP '(?:add|Finding)\("\KCCV-L\d+' tools/lint-rtl.py | sort -u)
missing=""
for r in $RULES; do
  grep -q "$r" "$TMP/bad.log" || missing="$missing $r"
done
if [ -n "$missing" ]; then
  bad "every lint rule has a counter-example" "never fired:$missing"
else
  say "every lint rule fires on the fixture ($(echo "$RULES" | wc -w) rules)" "PASS"
fi

# Every rule must also be documented, or a failure points at a regex rather
# than at the paragraph explaining why the rule exists.
undoc=""
for r in $RULES; do
  grep -q "$r" "$GUIDE" 2>/dev/null || undoc="$undoc $r"
done
if [ -n "$undoc" ]; then
  bad "every lint rule is documented" "not in the style guide:$undoc"
else
  say "every lint rule is documented in the guide" "PASS"
fi

# -- the module namespace, refused by name (DA's response OI-37) -----------
# Each shape the lint must refuse, under the rule that refuses it, by the
# module's or the block's own name: a refusal that went quiet is named here,
# not hidden among the others that still fire.
nmiss=""
for want in "CCV-L28: module widget:" "CCV-L28: module ccv_nosuch:" \
            "CCV-L28: module ccv_nosuch_w:" "CCV-L28: module ccv_reference_pick:" \
            "CCV-L28: module ccv_common:" "CCV-L28: module reference_common:" \
            "CCV-L22: module ccv_reference is a block top" \
            "CCV-L22: module ccv_top is the core top" \
            "CCV-L22: module ccv_reference_w instantiates" \
            "CCV-L22: module reference_gated instantiates" \
            "CCV-L22: module reference_ungated is a sub-block" \
            "CCV-L22: module reference_borrowed is a sub-block" \
            "CCV-L22: module ccv_common_rpt_gated instantiates" \
            "CCV-L28: block fet's module is ccv_fetch" \
            "CCV-L28: block common is a reserved" "CCV-L28: block top is a reserved" \
            "CCV-L28: block ooe_w is not one" "CCV-L28: block Lane is not one" \
            "CCV-L28: module ccv_core_top:" \
            "CCV-L27: module ccv_common_sram_wide is named as a hard macro"; do
  grep -qF "$want" "$TMP/names.log" || nmiss="$nmiss [$want]"
done
nn=$(grep -c "CCV-L2[28]" "$TMP/names.log")
if [ -n "$nmiss" ]; then
  bad "every namespace shape refused by name" "not refused:$nmiss"
elif [ "$nn" != 19 ]; then
  bad "every namespace shape refused by name" "$nn refusals, want exactly the 19 named"
else
  say "module namespace: 19 refusals, each by name" "PASS"
fi

# -- a comparison is not an assignment, and reading one consumes nothing ----
# CCV-L20, L23 and L24 read assignments, and `==`, or `<=` in a condition or
# a macro call, read as one too (OI-40). Refusing a comparison is half of it:
# the other half is that the refusal does not swallow the statement after
# it, which is a rule going quiet with nothing to show. So each finding
# behind a comparison must name the net that is wrong, not the one compared.
amiss=""
for want in "CCV-L23: out_i_cy03h is at stage 03" \
            "CCV-L20: clock 'core_clk' is read as data by 'out_i_cy00h'"; do
  grep -qF "$want" "$TMP/bad.log" || amiss="$amiss [$want]"
done
if [ -n "$amiss" ]; then
  bad "assignments behind a comparison are read" "not found:$amiss"
elif grep -qE "read as data by '(in_data_cy00h|a_cy00h)'|CCV-L23: in_data_cy00h " "$TMP/bad.log"; then
  bad "assignments behind a comparison are read" \
    "a comparison read as an assignment: $(grep -m1 -E "by '(in_data|a)_cy00h'|L23: in_data_cy00h " "$TMP/bad.log")"
else
  say "assignments behind a comparison are read" "PASS"
fi

# -- compliant code must be SILENT -----------------------------------------
# The false-positive regression, and it matters more than usual for the
# X-determinism rules: a rule that fires on correct code gets switched off, and
# a rule that is switched off protects nothing. reference_common_xprop.sv exercises all
# three legal routes on control inputs exactly as suspicious as the fixture's.
gfail=0
# One fixture per shape the namespace accepts: a block top, its wrapper, a
# sub-block and two common modules, all of the lint fixtures' own block. And
# reference_compare.sv: comparisons in a condition and in a macro call with
# no semicolon, each of which drew a finding before OI-40.
for g in rtl/lint/reference_common_xprop.sv rtl/lint/ccv_reference.sv \
         rtl/lint/ccv_reference_w.sv rtl/lint/reference_gated_enable.sv \
         rtl/lint/reference_common_yosys.sv rtl/lint/reference_compare.sv \
         rtl/lint/reference_feedback.sv rtl/lint/reference_loop.sv \
         rtl/lint/reference_table.sv rtl/lint/reference_table2.sv \
         rtl/lint/reference_table3.sv rtl/lint/reference_top.sv \
         rtl/lint/reference_rd.sv rtl/lint/reference_wr.sv \
         rtl/lint/reference_pp.sv rtl/lint/reference_pc.sv rtl/lint/reference_ph.sv \
         rtl/lint/reference_tpp.sv rtl/lint/reference_tpr.sv rtl/lint/reference_tpw.sv \
         rtl/lint/reference_hp.sv rtl/lint/reference_xp.sv rtl/lint/reference_xc.sv; do
  if ! python3 tools/lint-rtl.py "$g" >"$TMP/good.log" 2>&1; then
    bad "compliant code is silent ($g)" "$(grep -m1 'CCV-L' "$TMP/good.log")"
    gfail=1
  fi
done
[ "$gfail" = "0" ] && say "compliant code is silent (23 fixtures)" "PASS"

# CCV-L23's feedback (OI-65): a register reading state of its own stage, and
# a D-side net reading the state it feeds, pass (reference_feedback.sv, above);
# an assign is checked like an always_comb, and a D-side net read anywhere but
# a flop is held to the plain arithmetic.
for want in "mis_cy02h is at stage 02 but combinational" "dnx_cy00h is at stage 00 but combinational"; do
  if grep -q "CCV-L23: $want" "$TMP/bad.log"; then
    say "CCV-L23 refuses ${want%% is at*}" "PASS"
  else
    bad "CCV-L23 refuses ${want%% is at*}" "no finding"
  fi
done

# CCV-L23's declared feedback (OA's ruling on TI-38): reference_loop.sv's
# declared back edge passes (above). bad_feedback.sv's are refused: one with
# no loop behind it, which leaves its stage skip reported; one not an
# architect's; one for a read its reader does not make; and the same loop as
# reference_loop's, undeclared, which the arithmetic refuses. Its declared
# bypass passes too (DA, 2026-10-23; OI-72 (A)), and its if's condition
# counts; bad_feedback.sv's bypass of another pipeline's register, its bypass
# at an offset the tags do not give, and a stage-03 read in an if's condition
# (OI's rev 188) are refused.
while IFS='|' read -r what want; do
  if grep -qF "$want" "$TMP/bad.log"; then
    say "CCV-L23 feedback refused: $what" "PASS"
  else
    bad "CCV-L23 feedback refused: $what" "no finding: $want"
  fi
done <<'WANT'
no loop behind it|req_cy02h reads stat_cy03h as declared feedback, but no register
...and its stage skip reported|req_cy02h is at stage 02 but sequential logic over stage(s) 01,03
not an architect's|own_cy02h's declared feedback reads are not an architect's
a read not made|x_cy02h is declared to read stat_cy03h as feedback, but does not read it
the loop undeclared|rqn_cy02h is at stage 02 but sequential logic over stage(s) 01,03
a listed hop that does not exist|q1_cy02h's declared loop q1_cy02h -> q3_cy04h for its read of q3_cy04h does not hold: no hop from q1_cy02h to q3_cy04h
a longer loop not listed|p1_cy02h reads p3_cy04h as declared feedback, but no register
an alignment the tags do not give|m1_cy02h (stage 02) reads m2_cy03h (stage 03), 1 stage(s) ahead, but is declared 2 ahead
...and its stage skip reported|m1_cy02h is at stage 02 but sequential logic over stage(s) 01,03
no alignment declared|n1_cy02h's declared feedback reads give no alignment
a bypass whose source is off the reader's path|offp_cy02h's declared bypass of o2_cy03h does not hold: o2_cy03h is not loaded, 1 register(s) back, from a register at offp_cy02h's stage 02 in its pipeline
...and its stage skip reported|offp_cy02h is at stage 02 but combinational logic over stage(s) 02,03
a bypass at an offset the tags do not give|wofs_cy02h (stage 02) reads w2_cy03h (stage 03), 1 stage(s) ahead, but its bypass is declared 2 ahead
a stage-03 read in an if's condition|cnd_cy02h is at stage 02 but combinational logic over stage(s) 02,03
WANT

# CCV-L23's declared table (DA rev 131, OA 452's seven conditions):
# reference_table.sv, ooe_ratmap's shape, passes (above). bad_table.sv's
# are refused, one condition each: a declared scalar, an index not at the
# reader's stage, a table whose tag is not its writer's, a reader that does
# not read it, a declaration not an architect's, and a module with no
# assertion; and the shape undeclared, whose read the arithmetic refuses.
while IFS='|' read -r what want; do
  if grep -qF "$want" "$TMP/bad.log"; then
    say "CCV-L23 table refused: $what" "PASS"
  else
    bad "CCV-L23 table refused: $what" "no finding: $want"
  fi
done <<'WANT'
a declared scalar|table spark_cy04h is refused: spark_cy04h is not an array
an index not at the reader's stage|table mpark_cy04h's read by mrd_cy01h is refused: its index 'mri_in_cy00h' is at stage 00, not the reader's own (01)
a tag not its writer's|table bpark_cy05h is refused: bpark_cy05h is tagged stage 05, but its writes' data, index and enable reach stage 03
a reader that does not read|table npark_cy04h lists reader nrd_out_cy02h, which does not read it
not an architect's|table opark_cy04h is refused: not an architect's (by 'OI'
no assertion|table apark_cy04h is refused: reference_tnoassert holds no assertion naming its write enable
...and each refused read's stage skip reported|ord_cy01h is at stage 01 but combinational logic over stage(s) 01,04 gives 04
undeclared, the arithmetic refuses it|urd_cy01h is at stage 01 but combinational logic over stage(s) 01,04 gives 04
WANT

# Two writers (OA-479 (b); Daniel, 2026-11-24): reference_table2.sv,
# dcu_bctl's fold-table shape (a lookup's read-modify-write loop and a fill
# at stage 04 at one port), passes (above). bad_table2.sv's are refused: a
# fill enable asserted against no read, a third writer not declared, and a
# fill enable asserted against no loop enable (DI-42's write conflict); and
# each refused port's stage skip stays reported. reference_table3.sv, the
# fold table as DI wrote it (DI-51: row registers in a generate loop, each
# written and read under a compare of a tagged index with its row number,
# the lookup's enable a net through the generate block), passes;
# bad_table3.sv's row compare a stage early, and a declaration leaving
# out the rows' own read-modify-write (DI-53), are refused.
while IFS='|' read -r what want; do
  if grep -qF "$want" "$TMP/bad.log"; then
    say "CCV-L23 two-writer table refused: $what" "PASS"
  else
    bad "CCV-L23 two-writer table refused: $what" "no finding: $want"
  fi
done <<'WANT'
an unasserted second enable|table ntab_cy03h is refused: writer fill's enable (nfe_cy04h) is named in no assertion with the read
an undeclared second writer|table utab_cy03h is refused: an undeclared writer reaches its write port: ugd_cy05h, uge_cy05h, ugi_cy05h, at stage 05
no write-conflict assertion|table ctab_cy03h is refused: writer fill's enable (cfe_cy04h) is named in no assertion with the loop writer's (cle_cy02h)
a row compare not at the reader's stage|table mtab_cy03h's read by mrd_cy02h is refused: its index 'mli_cy01h' is at stage 01, not the reader's own (02)
a row's own read not listed|table otab_cy03h is refused: its loop writer lookup reads no listed reader
...and the refused port's stage skip reported|upe_cy02h is at stage 02 but combinational logic over stage(s) 02,04,05 gives 05
WANT

# reference_hp.sv: a register loop whose hop crosses a register-free helper,
# traced as the parent's logic (OI-213), passes; reference_xp.sv names a
# crossing of a child's combinational path, "u_x.a_cy02h>y_cy02h" (OA-494),
# and passes; bad_conn3.sv's named crossing of a registered path is refused.
# reference_tpp/tpr/tpw: a table read through an input port (OA-492 (3)),
# rob_w and redir's shape, passes; bad_tport.sv's wrong ahead, port fed
# through logic and missing assertion are refused.
# reference_pp.sv: a loop closed by two parent registers, declared hop by
# hop (OI-207, OA-489), and a register-free helper in a same-stage self-loop,
# exempt (OA-488 (1)); bad_conn2.sv's untraced hop and helper feeding a
# second register are refused.
# CCV-L23 across a connection (OA 481-483; TI-554..556): reference_top.sv,
# the MIU L0 refill's shape, with its cross-module loop declared, passes
# (above). bad_conn.sv's are refused: the loop undeclared, an untagged child
# port, a wrong "ahead", a loop that does not close, and a declaration with
# no assertion; and the ratchet excuses a listed back edge, refuses a stale
# entry, and refuses one not in its baseline.
while IFS='|' read -r what want; do
  if grep -qF "$want" "$TMP/bad.log"; then
    say "CCV-L23 connection refused: $what" "PASS"
  else
    bad "CCV-L23 connection refused: $what" "no finding: $want"
  fi
done <<'WANT'
an undeclared back edge|reference_utop's u_rd (reference_urd): output ms_cy03h (its stage 03, the parent's 03) depends on input l0_cy02h (its stage 02, fed at 06), so the parent tags it 4 stage(s) earlier
an untagged port on a connection|reference_ntop's u_rd.l0 is connected to nl0_cy06h, and the child's port carries no stage tag
a wrong ahead|cross-module loop u_rd.l0_cy02h is refused: ahead is 3, but the net lies 4 stage(s) past the input's tag
a loop that does not close|cross-module loop u_rd.l0_cy02h is refused: the loop does not close: no output of u_rd reaches an input of u_wr
no stale-read assertion|cross-module loop u_rd.l0_cy02h is refused: no assertion 'conn_l0_fresh' in the parent or reference_ard
a port table's wrong ahead|table rd_cy04h (an input port) is refused: ahead is 2, but rd_cy04h lies 1 stage(s) past its reader's (03)
a port table fed through logic|table rd_cy04h (an input port) is refused: in reference_gtpp, rd_cy04h is not fed directly by u_w's register rd_cy04h
a port table with no assertion|table rd_cy04h (an input port) is refused: no assertion 'hd_read_not_written' in reference_stpr
a registered crossing|cross-module loop u_c.v_cy01h is refused: crossing u_q.a_cy02h>y_cy03h: reference_qqreg has no combinational path from a_cy02h to y_cy03h
a register loop's untraced hop|cross-module loop u_c.v_cy01h is refused: the loop's hop rm_cy03h -> rm_cy04h is not traced
a helper whose output feeds another register|reference_hpp's u_h (reference_hph): output y (its stage none, the parent's 02) depends on input a (its stage none, fed at 03) combinationally
a control no bench names|cross-module loop u_rd.l0_cy02h is refused: its control 'conn-l0-nosuch' is named nowhere
WANT
python3 tools/lint-rtl.py --conn-ratchet=rtl/lint/bad_conn_ratchet.json \
  --conn-baseline=rtl/lint/bad_conn_baseline.json rtl/lint/bad_conn.sv >"$TMP/cratchet.log" 2>&1
if ! grep -q "reference_utop's u_rd (reference_urd)" "$TMP/cratchet.log" &&
   grep -q "reference_utop.u_wr ms_cy03h now meets the rule" "$TMP/cratchet.log" &&
   grep -q "reference_utop.u_rd a_cy01h was not on the list" "$TMP/cratchet.log"; then
  say "CCV-L23's connection ratchet excuses, and only shrinks" "PASS (listed excused; stale and unlisted refused)"
else
  bad "CCV-L23's connection ratchet" "$(grep 'CCV-L23' "$TMP/cratchet.log" | head -3)"
fi

# An orphan declaration (MI-44): a <module>.feedback.json beside no .sv
# defining that module is never read, so it is refused.
mkdir -p "$TMP/orphan"
cp rtl/lint/reference_hp.feedback.json "$TMP/orphan/ghost_miu.feedback.json"
python3 tools/lint-rtl.py --orphan-root="$TMP/orphan" rtl/lint/reference_hp.sv >"$TMP/orphan.log" 2>&1
if grep -q "ghost_miu.feedback.json is declared for module ghost_miu, which no .sv beside it defines" "$TMP/orphan.log"; then
  say "CCV-L23: an orphan feedback declaration is refused" "PASS"
else
  bad "CCV-L23: an orphan feedback declaration" "no finding: $(head -2 "$TMP/orphan.log" | tr '\n' ' ')"
fi

# MA signs a declaration under rtl/miu/ or rtl/dcu/ only (MA-32): the
# reference table, signed by MA, passes read as a DCU module and is refused
# read as an OOE one.
mkdir -p "$TMP/ma"
cp rtl/lint/reference_table.sv "$TMP/ma/"
sed 's/"by": "OA"/"by": "MA"/' rtl/lint/reference_table.feedback.json >"$TMP/ma/reference_table.feedback.json"
python3 tools/lint-rtl.py --signer-path=rtl/dcu "$TMP/ma/reference_table.sv" >"$TMP/ma-dcu.log" 2>&1; ma_dcu=$?
python3 tools/lint-rtl.py --signer-path=rtl/ooe "$TMP/ma/reference_table.sv" >"$TMP/ma-ooe.log" 2>&1
if [ "$ma_dcu" = 0 ] && grep -q "table park_cy04h is refused: not an architect's (by 'MA'" "$TMP/ma-ooe.log"; then
  say "CCV-L23: MA signs only for MIU and DCU" "PASS (a DCU table passes; an OOE one is refused)"
else
  bad "CCV-L23: MA signs only for MIU and DCU" "dcu exit $ma_dcu: $(grep -m1 'CCV-L' "$TMP/ma-dcu.log"); ooe: $(grep -m1 'CCV-L23' "$TMP/ma-ooe.log")"
fi

# CCV-L29 (DA, 2026-10-23): an untagged net at module level and one in a
# generate block are refused, and ccv_reference.sv's struct field, function
# local and procedural local, which are not nets, pass (above). Its ratchet
# excuses what it lists, and refuses an entry that now meets the rule and one
# that was not in the baseline when the rule was made.
for want in untag_nx untag_par; do
  if grep -q "CCV-L29: net $want of module" "$TMP/bad.log"; then
    say "CCV-L29 refuses $want, untagged" "PASS"
  else
    bad "CCV-L29 refuses $want, untagged" "no finding"
  fi
done
python3 tools/lint-rtl.py --stage-ratchet=rtl/lint/bad_stage_ratchet.json \
  --stage-baseline=rtl/lint/bad_stage_baseline.json rtl/lint/bad_naming.sv >"$TMP/ratchet.log" 2>&1
if ! grep -q "CCV-L29: net untag_nx" "$TMP/ratchet.log" &&
   grep -q "CCV-L29: net untag_par" "$TMP/ratchet.log" &&
   grep -q "CCV-L29: ccv_reference out_d_cy01h now meets the rule" "$TMP/ratchet.log" &&
   grep -q "CCV-L29: ccv_reference never_listed was not on the list" "$TMP/ratchet.log"; then
  say "CCV-L29's ratchet excuses, and only shrinks" "PASS (listed excused; tagged and unlisted refused)"
else
  bad "CCV-L29's ratchet" "$(grep 'CCV-L29' "$TMP/ratchet.log" | head -3)"
fi

# CCV-L26 makes a claim about a TOOL, so the claim is checked against the
# tool: every form the rule permits must actually be readable by Yosys. A
# permitted form Yosys rejects would be the worst outcome available -- both
# simulators green, lint silent, formal dead -- so this is the direction that
# gets measured on every run. If a Yosys upgrade widens what it accepts, the
# rule is merely conservative; if one narrows it, this fails.
if command -v yosys >/dev/null 2>&1; then
  if yosys -q -p "read_verilog -sv -formal rtl/lint/reference_common_yosys.sv; \
                  prep -top reference_common_yosys" >"$TMP/l26.log" 2>&1; then
    say "yosys reads every form CCV-L26 permits" "PASS"
  else
    bad "yosys reads every form CCV-L26 permits" \
        "$(grep -m1 -i error "$TMP/l26.log")"
  fi
else
  say "yosys reads every form CCV-L26 permits" "SKIP -- yosys not installed"
fi

# -- the real tree is clean ------------------------------------------------
if python3 tools/lint-rtl.py -q >"$TMP/clean.log" 2>&1; then
  say "lint clean across rtl/, test/, spike/" "PASS"
else
  bad "lint clean across the tree" "$(head -3 "$TMP/clean.log" | tr '\n' ' ')"
fi

# -- shared parameters: one source, two languages, same values -------------
if python3 tools/gen-params.py --check >"$TMP/gen.log" 2>&1; then
  say "generated parameter files current" "PASS"
else
  bad "generated parameter files current" "$(head -1 "$TMP/gen.log")"
fi

# §9's actual concern is not that the files exist but that they cannot DRIFT.
# So compare the values, in both languages, against the source of truth --
# which is the check that would have caught the failure §9 describes, "a
# correlation run silently comparing two differently-sized machines".
if python3 - >/dev/null <<'PY'
import json, re, sys, os
root = os.getcwd()
src = json.load(open(os.path.join(root, "params/ccv_params.json")))
sv = open(os.path.join(root, "rtl/generated/ccv_params_pkg.sv")).read()
h = open(os.path.join(root, "sim/generated/ccv_params.h")).read()

# Mirrors tools/gen-params.py: provisional parameters lose the CCV_P_ prefix
# and land in ccv::prov, because the namespace is what keeps "unfinished"
# visible at the use site.
PROV = {"provisional", "tunable"}


def camel(n):
    parts = [p for p in n.split("_") if p != "CCV"]
    return "".join(p.capitalize() for p in parts)

bad = []
for p in src["params"]:
    name, val = p["name"], p["value"]
    # Each tier strips its own prefix on the C++ side, because the namespace
    # already carries it: ccv::prov::kWImm, ccv::prelim::kWOpcode. Mirroring
    # the generator here rather than restating the rule is the point -- this
    # check exists to catch the two drifting apart.
    prelim = p["status"] == "preliminary"
    prov = p["status"] in PROV and not prelim
    # Both packages live in one generated file; the value must appear once.
    m = re.search(r"localparam\s+int\s+%s\s*=\s*(\d+)\s*;" % re.escape(name), sv)
    if not m:
        bad.append("%s missing from SystemVerilog" % name)
    elif int(m.group(1)) != val:
        bad.append("%s: SV %s vs source %d" % (name, m.group(1), val))
    if prelim:
        cn = "k" + camel(name.replace("CCV_L_", ""))
    elif prov:
        cn = "k" + camel(name.replace("CCV_P_", ""))
    else:
        cn = "k" + camel(name)
    m = re.search(r"constexpr\s+uint32_t\s+%s\s*=\s*(\d+)\s*;" % re.escape(cn), h)
    if not m:
        bad.append("%s missing from C++ (as %s)" % (name, cn))
    elif int(m.group(1)) != val:
        bad.append("%s: C++ %s vs source %d" % (name, m.group(1), val))
if bad:
    sys.exit("; ".join(bad))
print("PARAMS MATCH")
PY
then
  say "C++ and RTL parameter values agree with source" "PASS"
else
  bad "C++ and RTL parameter values agree" "see above"
fi

exit $fail
