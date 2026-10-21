// Both forms of the frozen decode queue (vl_decq.sv) on the same inputs,
// for tools/check-vl-reorder.sh: `a_` is step(), `b_` the if/else form.
// A second copy of the inputs feeds b_, so the harness can plant a
// difference and show the comparison catches it.
module vl_reorder_top #(
  parameter int S = 4, Q = 12, D = 12, E = 6, R = 4, P = 16,
  localparam int LS = $clog2(S), LC = $clog2(D + 1), LR = $clog2(R + 1), LU = $clog2(Q + 1)
) (
  input  logic             clk,
  input  logic             rst,
  input  logic [E-1:0]     enq_v,
  input  logic [E*LS-1:0]  enq_slot,
  input  logic [E*P-1:0]   enq_pay,
  input  logic [E*P-1:0]   b_enq_pay,
  input  logic [S*LR-1:0]  deq_n,
  input  logic [S-1:0]     flush,
  output logic [S*LC-1:0]  a_cnt,   b_cnt,
  output logic [S*R-1:0]   a_hv,    b_hv,
  output logic [S*R*P-1:0] a_hp,    b_hp,
  output logic [LU-1:0]    a_used,  b_used
);
  vl_decq #(.IFELSE(0), .S(S), .Q(Q), .D(D), .E(E), .R(R), .P(P)) u_a (
    .ooe_core_clk(clk), .ooe_rst_r00h(rst), .enq_v_cq01h(enq_v), .enq_slot_cq01h(enq_slot),
    .enq_pay_cq01h(enq_pay), .deq_n_cq01h(deq_n), .flush_cq01h(flush),
    .cnt_cq02h(a_cnt), .head_v_cq02h(a_hv), .head_pay_cq02h(a_hp), .used_cq02h(a_used));
  vl_decq #(.IFELSE(1), .S(S), .Q(Q), .D(D), .E(E), .R(R), .P(P)) u_b (
    .ooe_core_clk(clk), .ooe_rst_r00h(rst), .enq_v_cq01h(enq_v), .enq_slot_cq01h(enq_slot),
    .enq_pay_cq01h(b_enq_pay), .deq_n_cq01h(deq_n), .flush_cq01h(flush),
    .cnt_cq02h(b_cnt), .head_v_cq02h(b_hv), .head_pay_cq02h(b_hp), .used_cq02h(b_used));
endmodule
