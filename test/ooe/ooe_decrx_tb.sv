//===-- ooe_decrx_tb.sv - ooe_decrx and its arrival compare, side by side --===//
//
// Bench harness only, never RTL: ooe_decrx (the slot and epoch tables) and
// ooe_decrx_keep (the inner helper that ooe_decq will time in its own input
// cone), wired as the stage wires them, so test/ooe/decrx_tb.cpp drives the
// events and the arrivals and reads every keep and every table. The helper's
// advance inputs are its own ports (kadv, kadn) only so the bench's
// no-adv-bypass control can withhold them; in the stage they are the same
// wires as ooe_decrx's.
//===----------------------------------------------------------------------===//
module ooe_decrx_tb #(
  parameter int S  = 4,
  parameter int E  = 6,
  parameter int NW = 32,
  parameter int EP = 3,
  localparam int LS = $clog2(S),
  localparam int LW = $clog2(NW)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic             ev_l_cq00h,
  input  logic [S-1:0]     adv_cq01h,
  input  logic [S-1:0]     kadv_cq01h,
  input  logic [S-1:0]     adn_cq01h,
  input  logic [S-1:0]     kadn_cq01h,
  input  logic [S-1:0]     rel_cq01h,
  input  logic [S-1:0]     al_v_cq01h,
  input  logic [S*LW-1:0]  al_warp_cq01h,
  input  logic [E-1:0]     arv_v_cq01h,
  input  logic [E*LW-1:0]  arv_warp_cq01h,
  input  logic [E*EP-1:0]  arv_ep_cq01h,
  output logic [E-1:0]     enq_v_cq01h,
  output logic [E*LS-1:0]  enq_slot_cq01h,
  output logic [S-1:0]     sv_cq02h,
  output logic [S*LW-1:0]  sw_cq02h,
  output logic [S*EP-1:0]  se_cq02h,
  output logic [S*EP-1:0]  sn_cq02h,
  output logic [S*EP-1:0]  s2_cq02h
);
  ooe_decrx #(.S(S), .NW(NW), .EP(EP)) u_rx (
    .ooe_core_clk, .ooe_rst_r00h, .ev_l_cq00h, .adv_cq01h, .adn_cq01h, .rel_cq01h,
    .al_v_cq01h, .al_warp_cq01h,
    .sv_cq02h, .sw_cq02h, .se_cq02h, .sn_cq02h, .s2_cq02h);
  ooe_decrx_keep #(.S(S), .E(E), .NW(NW), .EP(EP)) u_keep (
    .arv_v_cq01h, .arv_warp_cq01h, .arv_ep_cq01h, .adv_cq01h(kadv_cq01h),
    .adn_cq01h(kadn_cq01h), .sv_cq02h, .sw_cq02h, .se_cq02h, .sn_cq02h, .s2_cq02h,
    .enq_v_cq01h, .enq_slot_cq01h);
endmodule
