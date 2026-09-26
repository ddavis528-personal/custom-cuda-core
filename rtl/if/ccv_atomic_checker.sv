//===-- ccv_atomic_checker.sv - slots that move as one -------------------===//
//
// Spec: interface decisions (2026-09-24), acceptance attribute;
//       docs/skeleton.md
// Reusable: one instance per multi-slot channel instance; clk/rst_n are
//           generic formals.
//
// A rate > 1 channel is independent credited slots by default -- the
// permissive superset, since SPM and DCU need partial acceptance. A channel
// whose receiver can only take a whole group is marked `acceptance: atomic`,
// and that is meant to be a CHECKED property, not a comment. This is the
// check. Without it, marking a channel atomic would assert nothing, and the
// RTL collapsing to one counter on the strength of it would be unguarded.
//
// ATOMIC MEANS VALIDS AND CREDITS BOTH MOVE TOGETHER -- all slots or none,
// every cycle. The decision says "credits move together ... letting RTL
// collapse to one counter". Credits alone are not enough for that: if slots
// launched independently while credits returned in lockstep, the per-slot
// counts would drift apart and one counter could not represent them. So the
// valids are held to the same rule. (Recorded as an interpretation in
// docs/skeleton.md.)
//
// `enable` is the schema's atomic flag, OR a test override that can only
// switch the check ON. The bank generator hardwires the schema term, so a
// channel decided atomic cannot have its check switched off at run time.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_atomic_checker #(
  parameter int MODE    = `CCV_MODE_ASSERT,
  // No CHANNEL parameter: nothing here would read it, and the bank's
  // instance name already names the channel in any failure message.
  parameter int N       = 4        // slots in the channel instance
) (
  input logic         clk,
  input logic         rst_n,
  input logic         enable,
  input logic [N-1:0] valid,
  input logic [N-1:0] credit
);

  wire valid_none  = (valid  == '0);
  wire valid_all   = (valid  == {N{1'b1}});
  wire credit_none = (credit == '0);
  wire credit_all  = (credit == {N{1'b1}});

  `CCV_CONTRACT_M(MODE, atomic_valid,  !enable || valid_none  || valid_all)
  `CCV_CONTRACT_M(MODE, atomic_credit, !enable || credit_none || credit_all)

  // -- satisfiability (§3.3): a group can actually move -------------------
  `CCV_IF_SAT(group_sent,     enable && valid_all)
  `CCV_IF_SAT(group_credited, enable && credit_all)

endmodule

`undef CCV_CLK
`undef CCV_RST
