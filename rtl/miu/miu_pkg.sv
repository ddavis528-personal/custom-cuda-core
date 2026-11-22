//===-- miu_pkg.sv - MIU's own layouts: the memop queue's two views ---------===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 161): the module
//       partition's miu_mq and miu_pair rows).
//
// miu_mq holds each memop's ccv_ooe_miu_memop payload as it arrives, and
// shows it to its readers as two views of the same flops, split where the
// payload struct splits (ccv_interfaces.svh, ccv_ooe_miu_memop_t, packed:
// the first field is the most significant):
//
//   HI (the echo, read at R1): rob_tag, done_row, rs_idx, phys_dst, dst_pos,
//      phys_pred, issue_mask: the payload's top HI_W bits.
//   A1 (the address stage's fields, read by miu_pair at H-1): warp_id,
//      cta_slot, mem_op, chwidth, pipes, disp, scale_en, space, ordering,
//      slot_form, arg_slot, local_form, xfer_size, xfer_signed: the bottom
//      A1_W bits, whose field offsets follow (A1_<FIELD> is the LSB).
//
// miu_mq asserts at elaboration that HI_W + A1_W is the struct's width, so a
// schema change that moves a field fails the build here, not in a bench.
//===----------------------------------------------------------------------===//
package miu_pkg;

  /* verilator lint_off UNUSEDPARAM */

  localparam int HI_W = ccv_prov_pkg::CCV_P_W_ROB_TAG + 2 + ccv_prov_pkg::CCV_P_W_RS_IDX +
                        ccv_prov_pkg::CCV_P_W_PHYS_REG + ccv_params_pkg::CCV_W_PHYS_POS +
                        ccv_prov_pkg::CCV_P_W_PHYS_PRED + ccv_params_pkg::CCV_W_LANE_MASK;

  // A1 view, from bit 0 up.
  localparam int A1_XFER_SIGNED = 0;
  localparam int A1_XFER_SIZE   = A1_XFER_SIGNED + 1;
  localparam int A1_LOCAL_FORM  = A1_XFER_SIZE + 2;
  localparam int A1_ARG_SLOT    = A1_LOCAL_FORM + 1;
  localparam int A1_SLOT_FORM   = A1_ARG_SLOT + 4;
  localparam int A1_ORDERING    = A1_SLOT_FORM + 1;
  localparam int A1_SPACE       = A1_ORDERING + ccv_params_pkg::CCV_L_W_ORDERING;
  localparam int A1_SCALE_EN    = A1_SPACE + ccv_params_pkg::CCV_L_W_SPACE;
  localparam int A1_DISP        = A1_SCALE_EN + 1;
  localparam int A1_PIPES       = A1_DISP + ccv_params_pkg::CCV_W_DISP;
  localparam int A1_CHWIDTH     = A1_PIPES + ccv_params_pkg::CCV_MIU_PIPES;
  localparam int A1_MEM_OP      = A1_CHWIDTH + ccv_params_pkg::CCV_W_CHWIDTH;
  localparam int A1_CTA_SLOT    = A1_MEM_OP + ccv_prelim_pkg::CCV_L_W_MEM_OP;
  localparam int A1_WARP_ID     = A1_CTA_SLOT + ccv_prov_pkg::CCV_P_W_CTA_SLOT;
  localparam int A1_W           = A1_WARP_ID + ccv_params_pkg::CCV_W_WARP_ID;

  // A bulk discard's mem_op (A-41): a command that holds no entry.
  localparam logic [ccv_prelim_pkg::CCV_L_W_MEM_OP-1:0] MEM_OP_DISCARD = '1;

  /* verilator lint_on UNUSEDPARAM */

endpackage
