//===-- ccv_lockstep_checker.sv - instances that advance as one ----------===//
//
// Spec: interface decisions (revised 2026-09-25), lockstep attribute;
//       docs/skeleton.md
// Reusable: one instance per lockstep channel TYPE, spanning all of its
//           instances; clk/rst_n are generic formals.
//
// Every other checker looks inside one channel instance. This one looks
// ACROSS them. The 32 lane copies of rcu->lane and lane->rcu are one SIMD
// datapath, and nothing per-instance can say so: with per-lane flow control
// each lane is individually correct and the machine as a whole is not SIMD.
//
// Three properties, per slot k, across every instance:
//   lockstep_valid   slot k's valid is all-or-none across instances
//   lockstep_credit  slot k's credit is all-or-none across instances
//   lockstep_id      (CCV_TRACE) when slot k lands on every instance, every
//                    instance carries the SAME trace id -- the same
//                    instruction. This is what makes slot BINDING checkable:
//                    lane 3 taking instruction A in slot 0 while lane 7 takes
//                    it in slot 2 has matching valids and different ids.
//
// Stall is deliberately not required to match. A lane may stall on its own,
// provided the sender holds EVERY lane for it -- and the sender that does not
// is caught by lockstep_valid here plus stall_honoured on the stalled lane.
//
// Layout: instance-major, instance i's slots at [i*N +: N]; the bank
// generator lays the replicated channel's slots out contiguously that way.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_lockstep_checker #(
  parameter int MODE  = `CCV_MODE_ASSERT,
  parameter int INSTS = 32,       // instances that must advance together
  parameter int N     = 4         // slots per instance
) (
  input logic                 clk,
  input logic                 rst_n,
  input logic [INSTS*N-1:0]   valid,
  input logic [INSTS*N-1:0]   credit
`ifdef CCV_TRACE
  ,
  input logic [INSTS*N*64-1:0] tid
`endif
);

  logic [N-1:0] v_split, c_split;   // instances disagree on slot k
  logic [N-1:0] v_all;              // slot k valid on EVERY instance

  for (genvar k = 0; k < N; k++) begin : g_slot
    wire [INSTS-1:0] vk, ck;
    for (genvar i = 0; i < INSTS; i++) begin : g_inst
      assign vk[i] = valid[i*N + k];
      assign ck[i] = credit[i*N + k];
    end
    assign v_split[k] = (vk != '0) && (vk != {INSTS{1'b1}});
    assign c_split[k] = (ck != '0) && (ck != {INSTS{1'b1}});
    assign v_all[k]   = (vk == {INSTS{1'b1}});
  end

  `CCV_CONTRACT_M(MODE, lockstep_valid,  v_split == '0)
  `CCV_CONTRACT_M(MODE, lockstep_credit, c_split == '0)

`ifdef CCV_TRACE
  // The id rides with the payload, one cycle behind valid.
  logic [N-1:0] landed_all;
  always_ff @(posedge clk) begin
    if (!rst_n) landed_all <= '0;
    else        landed_all <= v_all;
  end

  logic [N-1:0] id_split;
  for (genvar k = 0; k < N; k++) begin : g_id
    wire [INSTS-1:0] same;
    for (genvar i = 0; i < INSTS; i++) begin : g_cmp
      assign same[i] = (tid[(i*N + k)*64 +: 64] == tid[k*64 +: 64]);
    end
    assign id_split[k] = landed_all[k] && (same != {INSTS{1'b1}});
  end
  `CCV_CONTRACT_M(MODE, lockstep_id, id_split == '0)
`endif

  // -- satisfiability (§3.3): the instances can move together at all -------
  `CCV_IF_SAT(all_sent,     v_all != '0)
  `CCV_IF_SAT(all_credited, c_split == '0 && credit != '0)

endmodule

`undef CCV_CLK
`undef CCV_RST
