//===-- ooe_decrx_tb.sv - ooe_decrx with its tables shown ------------------===//
//
// Bench harness only, never RTL: ooe_decrx, with its slot tables brought out
// by hierarchical reference, so test/ooe/decrx_tb.cpp drives the events and
// the arrivals (in their lead cycle) and reads every verdict (from its flops) and
// every table.
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
  input  logic [S:0]       ev_l_cq00h,
  input  logic [S-1:0]     adv_cq01h,
  input  logic [S-1:0]     adn_cq01h,
  input  logic [S-1:0]     rel_cq01h,
  input  logic [S-1:0]     al_v_cq01h,
  input  logic [S*LW-1:0]  al_warp_cq01h,
  input  logic [E-1:0]     arv_v_cq01h,
  input  logic [E*LW-1:0]  arv_warp_cq01h,
  input  logic [E*EP-1:0]  arv_ep_cq01h,
  output logic [E-1:0]     enq_v_cq02h,
  output logic [E*LS-1:0]  enq_slot_cq02h,
  output logic [S-1:0]     sv_cq02h,
  output logic [S*LW-1:0]  sw_cq02h,
  output logic [S*EP-1:0]  se_cq02h,
  output logic [S*EP-1:0]  sn_cq02h,
  output logic [S*EP-1:0]  s2_cq02h
);
  ooe_decrx #(.S(S), .E(E), .NW(NW), .EP(EP)) u_rx (
    .ooe_core_clk, .ooe_rst_r00h, .ev_l_cq00h, .adv_cq01h, .adn_cq01h, .rel_cq01h,
    .al_v_cq01h, .al_warp_cq01h, .arv_v_cq01h, .arv_warp_cq01h, .arv_ep_cq01h,
    .enq_v_cq02h, .enq_slot_cq02h, .sw_o_cq02h(sw_cq02h), .sn_o_cq02h(sn_cq02h));
  // The warp and the epoch after it are the module's outputs (ooe_redir's
  // reads, OI-179), so the bench checks them there.
  assign sv_cq02h = u_rx.sv_cq02h;
  assign se_cq02h = u_rx.sei_cq02h;
  assign s2_cq02h = u_rx.s2i_cq02h;
endmodule
