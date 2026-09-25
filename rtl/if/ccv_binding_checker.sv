//===-- ccv_binding_checker.sv - a slot carries its own group ------------===//
//
// Spec: skeleton review response (2026-09-25), binding_key;
//       docs/skeleton.md
// Reusable: one instance per channel instance with a binding key; clk/rst_n
//           are generic formals.
//
// `slot_binding: bound` says slot index carries meaning. Until a payload
// field NAMES the group a message belongs to, that meaning is text: nothing
// can tell a message in the wrong group from one in the right one. With a
// binding key (fet->dec's tier1_id), it is a check: the key must equal
// slot / GROUP on every message.
//
// The key is read when the PAYLOAD is on the wire, the cycle after valid --
// valid leads payload by one on every interface.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_binding_checker #(
  parameter int MODE  = `CCV_MODE_ASSERT,
  parameter int N     = 2,        // slots in the channel instance
  parameter int GROUP = 1,        // slots per binding group
  parameter int W     = 1         // key width
) (
  input logic           clk,
  input logic           rst_n,
  input logic [N-1:0]   valid,
  input logic [N*W-1:0] key       // slot s's key at [s*W +: W]
);

  logic [N-1:0] due_q;            // payload on the wire this cycle
  always_ff @(posedge clk) begin
    if (!rst_n) due_q <= '0;
    else        due_q <= valid;
  end

  // Flat vector and generate-for rather than an unpacked array or a cast:
  // Yosys reads neither (CCV-L26).
  logic [N-1:0] ok;
  for (genvar s = 0; s < N; s++) begin : g_slot
    localparam int WANT = s / GROUP;
    assign ok[s] = !due_q[s] || key[s*W +: W] == WANT[W-1:0];
  end

  `CCV_CONTRACT_M(MODE, binding_key, ok == {N{1'b1}})

  // -- satisfiability (§3.3): every slot can carry a message --------------
  `CCV_IF_SAT(all_due, due_q == {N{1'b1}})

endmodule

`undef CCV_CLK
`undef CCV_RST
