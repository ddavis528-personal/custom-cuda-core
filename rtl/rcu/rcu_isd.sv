//===-- rcu_isd.sv - RCU issue class: a slot's class, from its lead -------===//
//
// Spec: docs/design-snapshots/rcu-arch-partition.md (the issue end);
//       RA-43 (zero-cycle issue: RA rev 113, RA rev 117's lead_opcode class
//       flops); RI-25 (one shared capture).
//
// The issue end is zero-cycle (RA-43): a slot's payload reaches RCU's
// logic in A with no interface flop, and the logic before its first flop
// is held to the 12 NGD the port budget leaves (ccv_rcu arriving at 13).
// The op-class decode (rcu_dec_pkg::rcu_cls, the model's own) is far deeper
// than that from the payload's opcode. Its inputs ride the channel a cycle
// early as lead fields: lead_opcode, lead_done_row, lead_pred_we and
// lead_phys_dst, beside the slot's valid in A-1. This module decodes them
// there and keeps each slot's class word for A, so every module reads its
// slots' classes from these flops (arrival the fanout term) in place of
// decoding the payload's opcode.
//
// One capture for the block, not one per module: the class of a slot is
// the model's rcu_cls(opcode, done_row, pcopy) with pcopy = pred_we &&
// phys_dst == the zero GPR (only the copy-only op reads it). Where a module
// had called rcu_cls with done_row or pcopy tied to 0, the fields it reads
// are the same for every opcode a slot can carry (checked exhaustively,
// RI-25), but for an atomic on R's slot, which OOE never issues there
// (R's slot carries only R's ops: CCV_ISSUE_SLOT_R).
//
// One slot an instance (ccv_rcu instantiates nine): the class decode is
// rcu_dec_pkg::rcu_cls_a1, the same class as rcu_cls built for depth
// (15.6 NGD from lead_opcode as a case; 12.4 so, with the fanout term and
// the pcopy compare; nine in one netlist mapped deeper). The issue end's
// in-side is 12: lead_opcode's budget is RI-26's, with RA and AR.
//
// Clock gating: one gate (CLS_W flops), enabled by the slot's
// valid, an input: a CG-5 lead waiver (Daniel's ruling on RI-15, RA rev
// 87), its flops charged to the block's 2%. No reset: a class is read only
// under the slot's payload valid, a cycle after it is loaded.
//===----------------------------------------------------------------------===//
module rcu_isd #(
  localparam int OW = rcu_dec_pkg::OPC_W,                    // 9
  localparam int WR = ccv_prov_pkg::CCV_P_W_PHYS_REG,        // 8
  localparam int CW = rcu_dec_pkg::CLS_W                     // 27
) (
  input  logic          rcu_core_clk,
  // The slot's lead, in A-1 beside its valid.
  input  logic          iv_cr01h,     // ooe_rcu_issue_s*_valid
  input  logic [OW-1:0] lop_cr01h,    // lead_opcode
  input  logic [1:0]    ldrw_cr01h,   // lead_done_row
  input  logic          lpwe_cr01h,   // lead_pred_we
  input  logic [WR-1:0] ldst_cr01h,   // lead_phys_dst
  // The slot's class in A, straight from flops.
  output logic [CW-1:0] cls_cr02h
);

  localparam logic [WR-1:0] ZROW = WR'(ccv_prov_pkg::CCV_P_PHYS_ZERO);

  wire cls_en_cr01h = iv_cr01h;
  wire pc_cr01h = lpwe_cr01h && ldst_cr01h == ZROW;
  always_ff @(posedge rcu_core_clk) begin
    if (cls_en_cr01h)
      cls_cr02h <= rcu_dec_pkg::rcu_cls_a1(lop_cr01h, ldrw_cr01h, pc_cr01h);
  end
endmodule
