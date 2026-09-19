//===-- ccv_xprop.svh - X-propagation constructions --------------*- SV -*-===//
//
// §6 of the strategy doc requires X-correctness to be designed in by coding
// convention rather than inherited from tool semantics, because neither
// available simulator has dependable X-prop behaviour: Icarus implements the
// LRM's rules, which are themselves X-optimistic, and Verilator is 2-state.
// There is no VCS-equivalent X-propagation mode anywhere in the flow.
//
// This file records the constructions that reproduce VCS X-Prop semantics
// using nothing but LRM behaviour, and the primitives that make the more
// verbose ones convenient. Every claim below was measured -- see
// docs/stage1a-findings.md F-16.
//
//===----------------------------------------------------------------------===//
//
// THE RULE: a selection on control must be X-DETERMINISTIC.
//
// Exactly three constructions are legal. Anything else is X-optimistic, which
// means the bug is invisible rather than merely unhandled.
//
//   1. PROHIBITION   `if`/`case` whose control inputs carry `CCV_ASSERT_KNOWN.
//                    The strongest of the three: X is flagged at its source
//                    rather than tracked through the design. Preferred where
//                    it applies, which is most control.
//
//   2. TMERGE        The ternary operator. Bits where the branches agree keep
//                    their value; bits where they differ go X. This is what
//                    VCS calls tmerge and it is already LRM behaviour -- no
//                    tool mode, no primitive, no pragma.
//
//   3. XMERGE        `case`/`casez` with an X-default covering everything the
//                    case assigns. Strictly more pessimistic than tmerge: the
//                    whole result goes X rather than only the ambiguous bits.
//                    Conservative, and the natural style for wide selects.
//
// MEASURED, with i0=1100 i1=1110 i2=1100 i3=1101 (bits 3,2 agree; 1,0 differ):
//
//   sel = 2'bxx      ternary tree  11xx     tmerge -- only ambiguous bits X
//                    case+default  xxxx     xmerge -- all bits X
//                    casex         1100     WRONG: silently matched branch 0
//
//   sel = 2'b1x      ternary tree  110x     narrows correctly on PARTIAL X
//                    case+default  xxxx
//                    casex         1100     WRONG again
//
// `casex` is banned outright (CCV-L16). With an unknown selector it treats X
// as a don't-care and matches the FIRST branch, which is not pessimism or
// optimism but an arbitrary answer that looks like a real one.
//
//===----------------------------------------------------------------------===//
//
// WHY THE PRIMITIVES BELOW ARE CONVENIENCES, NOT REQUIREMENTS
//
// A chain of ternaries produces exact tmerge for any arity, because each level
// merges and merges compose. Two spellings, measured to be identical:
//
//     y = sel[1] ? (sel[0] ? i3 : i2)      // tree over the select bits
//                : (sel[0] ? i1 : i0);
//
//     y = (sel == 2'd0) ? i0 :             // chained equality
//         (sel == 2'd1) ? i1 :
//         (sel == 2'd2) ? i2 : i3;
//
// Both give 11xx at sel=xx and 110x at sel=1x. Both are plain Verilog needing
// no function, package or macro, and both narrow correctly on a PARTIALLY
// unknown selector -- which a hand-written merge function does not do without
// extra care.
//
// The macros below use the equality form, because bit-selecting a macro
// argument requires it to be a selectable name -- `(S)[1]` is not legal on a
// parenthesised expression -- while the equality form accepts any expression.
// They introduce no semantics of their own: code that spells either form
// directly is equally correct and equally lint-clean.
//
// WHERE THIS IS OBSERVABLE, WHICH IS ONE TOOL
//
// Being 2-state, Verilator cannot see any of this. Under formal an un-reset
// register is a free TWO-state value (F-8), so `$isunknown` is
// identically false and formal contributes nothing to X-propagation either.
// **Icarus is the only witness in the flow.** That makes the periodic X-pass
// (§6, and per block at Stage 4c) load-bearing rather than supplementary, and
// it is the argument for prohibition being the primary mechanism: an assertion
// fires in Icarus AND is provable under formal, while propagation is checkable
// in exactly one place.
//
//===----------------------------------------------------------------------===//
`ifndef CCV_XPROP_SVH
`define CCV_XPROP_SVH

// 2-way. Identical to writing the ternary; provided for symmetry with the
// wider forms so a design does not switch styles at arity 4.
`define CCV_XMUX2(S, I0, I1) ((S) ? (I1) : (I0))

// 4-way and 8-way, as chained equalities. S may be any expression.
`define CCV_XMUX4(S, I0, I1, I2, I3)                                    \
  (((S) == 2'd0) ? (I0) :                                               \
   ((S) == 2'd1) ? (I1) :                                               \
   ((S) == 2'd2) ? (I2) : (I3))

`define CCV_XMUX8(S, I0, I1, I2, I3, I4, I5, I6, I7)                    \
  (((S) == 3'd0) ? (I0) :                                               \
   ((S) == 3'd1) ? (I1) :                                               \
   ((S) == 3'd2) ? (I2) :                                               \
   ((S) == 3'd3) ? (I3) :                                               \
   ((S) == 3'd4) ? (I4) :                                               \
   ((S) == 3'd5) ? (I5) :                                               \
   ((S) == 3'd6) ? (I6) : (I7))

// Flop enable with an explicit hold, so an unknown enable merges rather than
// silently holding.
//
//     always_ff @(posedge clk) q <= `CCV_XHOLD(en, d, q);
//
// The bare form -- `always_ff @(posedge clk) if (en) q <= d;` -- is the single
// most common X-optimism bug in sequential logic: an unknown enable holds, and
// holding is indistinguishable from a correct decision not to load. Legal only
// when `en` is covered by prohibition.
`define CCV_XHOLD(EN, D, Q) ((EN) ? (D) : (Q))

// Synchronous reset plus enable, in one expression.
`define CCV_XHOLD_R(RST, RVAL, EN, D, Q) ((RST) ? (RVAL) : ((EN) ? (D) : (Q)))

`endif // CCV_XPROP_SVH
