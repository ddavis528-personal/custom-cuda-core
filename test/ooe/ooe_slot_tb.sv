//===-- ooe_slot_tb.sv - ooe_slot with its held demotes shown -------------===//
//
// Bench harness only, never RTL: ooe_slot, with its held-demote flops
// brought out by hierarchical reference, so test/ooe/slot_tb.cpp drives
// every input and reads every verdict, every slot and every held demote.
//===----------------------------------------------------------------------===//
module ooe_slot_tb #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int A  = 1,                  // allocations a cycle (ccv_rau_ooe_alloc's rate)
  parameter int D  = 1,                  // demotes a cycle (ccv_rau_ooe_demote's rate)
  parameter int NW = 32,                 // warp_ids (2 ** CCV_W_WARP_ID)
  parameter int WC = 32,                 // ctaid
  parameter int WI = 5,                  // warp_in_cta
  parameter int WB = 5,                  // barrier_count
  parameter int WT = 3,                  // cta_slot
  parameter int KE = 2,                  // kill_epoch
  localparam int LS = $clog2(S),
  localparam int LW = $clog2(NW)
) (
  input  logic                ooe_core_clk,
  input  logic                ooe_rst_r00h,
  input  logic                ev_l_cq00h,
  input  logic                kill_l_cq00h,
  input  logic [A-1:0]        al_v_cq01h,
  input  logic [A*LS-1:0]     al_slot_cq01h,
  input  logic [A*2-1:0]      al_op_cq01h,
  input  logic [A*LW-1:0]     al_warp_cq01h,
  input  logic [A*WC-1:0]     al_ctaid_cq01h,
  input  logic [A*WI-1:0]     al_wic_cq01h,
  input  logic [A*WB-1:0]     al_barc_cq01h,
  input  logic [A*WT-1:0]     al_cta_cq01h,
  input  logic [D-1:0]        dm_v_cq01h,
  input  logic [D*LW-1:0]     dm_warp_cq01h,
  input  logic [NW-1:0]       kill_mask_cq01h,
  input  logic [KE-1:0]       kill_ep_cq01h,
  input  logic [S-1:0]        held_cq01h,
  input  logic [S-1:0]        lnd_cq01h,
  input  logic [S-1:0]        ath_cq01h,
  input  logic [S-1:0]        xr_cq01h,
  input  logic [S-1:0]        ret_cq01h,
  output logic [S*3-1:0]      st_cq02h,
  output logic [S*LW-1:0]     warp_cq02h,
  output logic [S*WC-1:0]     ctaid_cq02h,
  output logic [S*WI-1:0]     wic_cq02h,
  output logic [S*WB-1:0]     barc_cq02h,
  output logic [S*WT-1:0]     cta_cq02h,
  output logic [S-1:0]        ntc_cq02h,
  output logic [S-1:0]        map_cq02h,
  output logic [S-1:0]        rel_cq02h,
  output logic [S-1:0]        drn_cq02h,
  output logic [S-1:0]        drn_ref_cq02h,
  output logic [S-1:0]        drn_kept_cq02h,
  output logic                kack_cq02h,
  output logic [KE-1:0]       kack_ep_cq02h,
  output logic [S-1:0]        dmh_cq02h
);
  ooe_slot #(.S(S), .A(A), .D(D), .NW(NW), .WC(WC), .WI(WI), .WB(WB), .WT(WT), .KE(KE)) u_sl (
    .ooe_core_clk, .ooe_rst_r00h, .ev_l_cq00h, .kill_l_cq00h, .al_v_cq01h, .al_slot_cq01h, .al_op_cq01h, .al_warp_cq01h, .al_ctaid_cq01h, .al_wic_cq01h, .al_barc_cq01h, .al_cta_cq01h, .dm_v_cq01h, .dm_warp_cq01h, .kill_mask_cq01h, .kill_ep_cq01h, .held_cq01h, .lnd_cq01h, .ath_cq01h, .xr_cq01h, .ret_cq01h, .st_cq02h, .warp_cq02h, .ctaid_cq02h, .wic_cq02h, .barc_cq02h, .cta_cq02h, .ntc_cq02h, .map_cq02h, .rel_cq02h, .drn_cq02h, .drn_ref_cq02h, .drn_kept_cq02h, .kack_cq02h, .kack_ep_cq02h);
  assign dmh_cq02h = u_sl.dmhq_cq02h;
endmodule
