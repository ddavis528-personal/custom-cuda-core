//===-- ooe_pl.svh - OOE issue payload: the RS entry's fields -----------===//
//
// Spec: OA 435 (2)(3) (re:OI-171): ooe_rcupl and ooe_mempl format their
//       channels' fields from the RS entry they are given at select, and
//       may share a package. The channels are ccv_ooe_rcu_issue and
//       ccv_ooe_miu_memop (schema/interfaces.json).
//
// What an RS entry holds for its issue, as rename writes it: the fields of
// ccv_ooe_rcu_issue an op's lead message carries, each already in the form
// the channel sends (the immediate zero unless the op sends one, the copy
// op's opcode, a name's row and position apart), and for an MIU entry the
// memop channel's own fields beside them. The cta_slot is the warp's, a
// fixed property while the warp holds any entry, so it is written with the
// entry (OA 435: a field cheaper to build at RS write stays in the RS
// payload).
//===----------------------------------------------------------------------===//
`ifndef OOE_PL_SVH
`define OOE_PL_SVH
`include "ccv_interfaces.svh"

// Yosys 0.33 takes no package that reads another's parameters, so these
// are compilation-unit typedefs, as ccv_interfaces.svh's are. Nor does it
// take a struct in a generate block or an array of structs, so the RTL
// unpacks an entry by concatenation in the order below, and the bench,
// which packs it through the struct, holds the two together.
localparam int OOE_PL_WT = ccv_prov_pkg::CCV_P_W_ROB_TAG;
localparam int OOE_PL_WW = ccv_params_pkg::CCV_W_WARP_ID;
localparam int OOE_PL_WL = ccv_params_pkg::CCV_W_LANE_MASK;
localparam int OOE_PL_WR = ccv_prov_pkg::CCV_P_W_PHYS_REG;
localparam int OOE_PL_WPP = ccv_prov_pkg::CCV_P_W_PHYS_PRED;
localparam int OOE_PL_NS = ccv_params_pkg::CCV_SECTIONS;
localparam int OOE_PL_WBG = ccv_prelim_pkg::CCV_P_W_BYP_GROUP;
localparam int OOE_PL_WPS = ccv_params_pkg::CCV_W_PHYS_POS;
localparam int OOE_PL_WCW = ccv_params_pkg::CCV_W_CHWIDTH;
localparam int OOE_PL_WOP = ccv_prelim_pkg::CCV_L_W_OPCODE;
localparam int OOE_PL_WIM = ccv_prov_pkg::CCV_P_W_IMM;

// The RCU issue's fields, as the entry holds them. fp is the footprint:
// lane sections (S0-S3), MIU pipes (P0-P3), or 0 for an RCU op (R).
typedef struct packed {
  logic [OOE_PL_WT-1:0]    rob_tag;
  logic [1:0]       done_row;
  logic [OOE_PL_WW-1:0]    warp_id;
  logic [OOE_PL_WL-1:0]    issue_mask;
  logic [OOE_PL_NS-1:0]    fp;
  logic [2:0]       src_used;
  logic             imm_used;
  logic             merge_used;
  logic             guard_used;
  logic [OOE_PL_WPP-1:0]   guard_pred;
  logic [OOE_PL_WOP-1:0]   opcode;
  logic [OOE_PL_WR-1:0]    phys_dst;
  logic [OOE_PL_WPS-1:0]   dst_pos;
  logic [OOE_PL_WCW-1:0]   dst_width;
  logic             pred_we;
  logic [OOE_PL_WPP-1:0]   phys_pred_dst;
  logic             pred_neg;
  logic [2*OOE_PL_WR-1:0]  phys_src;
  logic [OOE_PL_WR-1:0]    phys_src2;
  logic [OOE_PL_WR-1:0]    phys_old_dst;
  logic [OOE_PL_WPS-1:0]   old_dst_pos;
  logic [3*OOE_PL_WPS-1:0] src_pos;
  logic [OOE_PL_WPP-1:0]   phys_pred_old_dst;
  logic             merge_en;
  logic [OOE_PL_WBG-1:0]   bypass_group;
  logic [3*OOE_PL_WCW-1:0] src_width;
  logic [OOE_PL_WCW-1:0]   chwidth;
  logic [OOE_PL_WIM-1:0]   imm;
} ooe_ent_t;

// An MIU entry's memop fields beside them (ccv_ooe_miu_memop). The
  // memop's own destination, predicate and data width: an atomic's differ
// from its RCU issue's (V-72).
typedef struct packed {
  logic [OOE_PL_WR-1:0]                                 phys_dst;
  logic [OOE_PL_WPS-1:0]                                dst_pos;
  logic [OOE_PL_WPP-1:0]                                phys_pred;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_prelim_pkg::CCV_L_W_MEM_OP-1:0]     mem_op;
  logic [OOE_PL_WCW-1:0]                                chwidth;
  logic [ccv_params_pkg::CCV_W_DISP-1:0]         disp;
  logic                                          scale_en;
  logic [ccv_params_pkg::CCV_L_W_SPACE-1:0]      space;
  logic [ccv_params_pkg::CCV_L_W_ORDERING-1:0]   ordering;
  logic                                          slot_form;
  logic [3:0]                                    arg_slot;
  logic                                          local_form;
  logic [1:0]                                    xfer_size;
  logic                                          xfer_signed;
} ooe_mem_t;

// A bulk discard's fields (A-41, A-53): the branch's tag, the warp, its
// CTA slot and the youngest index, every other field zero (V-40).
typedef struct packed {
  logic [OOE_PL_WT-1:0]                             rob_tag;
  logic [OOE_PL_WW-1:0]                             warp_id;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0] cta_slot;
  logic [ccv_prov_pkg::CCV_P_W_ROB_IDX-1:0]  tail;
} ooe_dsc_t;

// Widths, as sums of the fields above and of the channels' (Yosys 0.33
// takes no $bits of a type): test/ooe/pl_tb.cpp holds each to its
// struct's and to the generated channel's.
localparam int OOE_PL_EW = OOE_PL_WT + 2 + OOE_PL_WW + OOE_PL_WL + OOE_PL_NS + 3 + 3 + OOE_PL_WPP +
    OOE_PL_WOP + OOE_PL_WR + OOE_PL_WPS + OOE_PL_WCW + 1 + OOE_PL_WPP + 1 + 2 * OOE_PL_WR + OOE_PL_WR +
    OOE_PL_WR + OOE_PL_WPS + 3 * OOE_PL_WPS + OOE_PL_WPP + 1 + OOE_PL_WBG + 3 * OOE_PL_WCW +
    OOE_PL_WCW + OOE_PL_WIM;
localparam int OOE_PL_MW = OOE_PL_WR + OOE_PL_WPS + OOE_PL_WPP + ccv_prov_pkg::CCV_P_W_CTA_SLOT +
    ccv_prelim_pkg::CCV_L_W_MEM_OP + OOE_PL_WCW + ccv_params_pkg::CCV_W_DISP + 1 +
    ccv_params_pkg::CCV_L_W_SPACE + ccv_params_pkg::CCV_L_W_ORDERING + 1 + 4 + 1 + 2 + 1;
localparam int OOE_PL_DW = OOE_PL_WT + OOE_PL_WW + ccv_prov_pkg::CCV_P_W_CTA_SLOT +
    ccv_prov_pkg::CCV_P_W_ROB_IDX;
// Two fields of ooe_ent_t others' slots read: the rob tag (its first)
// and the footprint.
localparam int OOE_PL_E_TAG_LSB = OOE_PL_EW - OOE_PL_WT;
localparam int OOE_PL_E_FP_LSB  = OOE_PL_EW - (OOE_PL_WT + 2 + OOE_PL_WW + OOE_PL_WL + OOE_PL_NS);
// ccv_ooe_rcu_issue_t: its payload fields, then its lead fields.
localparam int OOE_PL_IW = OOE_PL_WT + 2 + OOE_PL_WW + OOE_PL_WL + 2 * OOE_PL_WR + 3 * OOE_PL_WR + 1 +
    2 * OOE_PL_WPP + 3 + OOE_PL_NS + OOE_PL_WBG + 3 * OOE_PL_WPS + 3 * OOE_PL_WCW + 2 * OOE_PL_WPS +
    OOE_PL_WCW + OOE_PL_WOP + OOE_PL_WIM + OOE_PL_WCW +
    OOE_PL_NS + 3 + 3 + OOE_PL_WPP + OOE_PL_WOP + OOE_PL_WR + OOE_PL_WPS + OOE_PL_WCW + 2 + 1 +
    OOE_PL_WPP + 1 + 1 + OOE_PL_WIM + 2 * OOE_PL_WR + OOE_PL_WR + OOE_PL_WR + OOE_PL_WPS + 3 * OOE_PL_WPS;
// ccv_ooe_miu_memop_t.
localparam int OOE_PL_OW = OOE_PL_WT + 2 + ccv_prov_pkg::CCV_P_W_RS_IDX + OOE_PL_WR + OOE_PL_WPS +
    OOE_PL_WPP + OOE_PL_WL + OOE_PL_WW + ccv_prov_pkg::CCV_P_W_CTA_SLOT + ccv_prelim_pkg::CCV_L_W_MEM_OP +
    OOE_PL_WCW + ccv_params_pkg::CCV_MIU_PIPES + ccv_params_pkg::CCV_W_DISP + 1 +
    ccv_params_pkg::CCV_L_W_SPACE + ccv_params_pkg::CCV_L_W_ORDERING + 1 + 4 + 1 + 2 + 1;
`endif
