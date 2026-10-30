//===-- ccv_common_chk_distinct.sv - one message per key a cycle ------------===//
//
// Spec: OA's rev 279 (OI-85), distinct_key; docs/skeleton.md
// One instance per channel instance with a distinct key; clk/rst_n
// are generic formals.
//
// A free pool of slots lets two messages for the same receiver entry land
// in one cycle. Where the receiver's update takes one per entry a cycle
// (ooe_rob's done count, which then decrements by one or none), the
// sender holds the second: no two valid slots of a cycle carry the same
// key. Checked pairwise over the slots the payload is on.
//
// The key is read when the PAYLOAD is on the wire, the cycle after valid --
// valid leads payload by one on every interface.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_common_chk_distinct #(
  parameter int MODE = `CCV_MODE_ASSERT,
  parameter int N    = 2,         // slots in the channel instance
  parameter int W    = 1          // key width
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
  // Yosys reads neither (CCV-L26). Slot s clashes with any later slot t.
  logic [N-1:0] clash;
  for (genvar s = 0; s < N; s++) begin : g_slot
    logic [N-1:0] same;
    for (genvar t = 0; t < N; t++) begin : g_pair
      if (t > s) begin : g_later
        assign same[t] = due_q[t] && key[t*W +: W] == key[s*W +: W];
      end else begin : g_earlier
        assign same[t] = 1'b0;
      end
    end
    assign clash[s] = due_q[s] && |same;
  end

  `CCV_CONTRACT_M(MODE, distinct_key, clash == '0)

  // -- satisfiability (§3.3): every slot can carry a message --------------
  `CCV_IF_SAT(all_due, due_q == {N{1'b1}})

endmodule

`undef CCV_CLK
`undef CCV_RST
