//===-- ooe_rsread.sv - OOE RS read: a slot's granted entry, one-hot ------===//
//
// Spec: OA's rev 343, (A) (the payload read: slot k takes the granted
//       entry whose slot is k, a one-hot AND-OR over its class) and OA 435
//       (2)(3) (the issue and payload registers are ooe_rcupl's and
//       ooe_mempl's).
//
// An inner helper (ooe_rsread.ngd.json): combinational, no flops, timed in
// its parents. ooe_rs holds the entries (each one's fields and its home
// slot, one-hot) and ooe_sched the grant register; ooe_rcupl and ooe_mempl
// read them here, beside their own registers, through the grant register
// for the lead read and through their own late copy of it for the rest
// (CCV-NGD-5: the read is not ooe_rs's, whose outputs come from flops).
//
// Slot k's read is over the entries [E0, E1), its class: a home slot
// belongs to one class, so the others never match and are left out of the
// tree. Grants are one per slot (V-60; ooe_rs asserts it), so the OR is a
// select.
//===----------------------------------------------------------------------===//
module ooe_rsread #(
  parameter int N  = 45,   // RS entries
  parameter int K  = 9,    // home slots an entry names (its one-hot's width)
  parameter int K0 = 0,    // the first slot read
  parameter int KS = 9,    // slots read: K0 .. K0 + KS - 1
  parameter int E0 = 0,    // the class's entries: E0 .. E1 - 1
  parameter int E1 = 45,
  parameter int W  = 1     // bits read per entry
) (
  input  logic [N-1:0]    g_cq01h,   // the grants read through (the grant register, or a copy)
  input  logic [N*K-1:0]  h_cq01h,   // each entry's home slot, one-hot
  input  logic [N*W-1:0]  q_cq01h,   // each entry's fields
  output logic [KS-1:0]   v_cq01h,   // slot K0 + k is a granted entry's home
  output logic [KS*W-1:0] e_cq01h    // that entry's fields
);

  always_comb
    for (int k = 0; k < KS; k++) begin
      v_cq01h[k] = 1'b0;
      e_cq01h[k * W +: W] = '0;
      for (int e = E0; e < E1; e++) begin
        v_cq01h[k] = v_cq01h[k] | (g_cq01h[e] & h_cq01h[e * K + K0 + k]);
        e_cq01h[k * W +: W] = e_cq01h[k * W +: W] | ({W{g_cq01h[e] & h_cq01h[e * K + K0 + k]}} & q_cq01h[e * W +: W]);
      end
    end

endmodule
