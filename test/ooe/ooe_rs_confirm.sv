//===-- ooe_rs_confirm.sv - depth probe: confirmation into allocation ---===//
//
// Not a block: test/ooe/depth.sh synthesises it to measure the path that
// decides the RS's same-edge reuse (DA's response OI-39): ooe_confirm's
// confirmations, from flops, as ooe_rs's frees, through allocation into
// the row write.
//===----------------------------------------------------------------------===//
module ooe_rs_confirm #(parameter int N = 45, parameter int NR = 30, parameter int A = 4) (
  input  logic ooe_core_clk, input logic ooe_rst_r00h,
  input  logic [2*A-1:0] req, input logic [2*A*N-1:0] rd, input logic [4*A*N-1:0] rc,
  input  logic [4*A*A-1:0] gd, input logic [8*A*A-1:0] gc,
  input  logic [N-1:0] iss, input logic [N-1:0] miss, input logic [N-1:0] fin, input logic [N-1:0] prod,
  output logic [2*A-1:0] gv, output logic [2*A*$clog2(N)-1:0] gi, output logic [N-1:0] val,
  output logic [N*N-1:0] dep, output logic [2*N*N-1:0] code, output logic [N-1:0] rep);
  logic [N-1:0] conf, hcol;
  ooe_confirm #(.N(N)) cf(.ooe_core_clk, .ooe_rst_r00h, .iss_cq01h(iss), .dep_cq01h(dep), .miss_cq01h(miss),
                          .hcol_cq01h(hcol),                          .fin_cq01h(fin), .prod_cq01h(prod), .replay_cq02h(rep), .conf_cq01h(conf));
  ooe_rs #(.N(N), .NR(NR), .A(A)) rs(.ooe_core_clk, .ooe_rst_r00h, .req_cq01h(req), .row_dep_cq01h(rd),
                          .row_code_cq01h(rc), .grp_dep_cq01h(gd), .grp_code_cq01h(gc), .free_cq01h(conf),
                          .gnt_v_cq02h(gv), .gnt_idx_cq02h(gi), .valid_cq02h(val), .dep_cq02h(dep), .code_cq02h(code),
                          .hcol_cq02h(hcol));
endmodule
