//===-- ooe_trio.sv - ooe_rs, ooe_wake and ooe_sched wired together --===//
//
// The assembled check's top (OA's response OI-45): the three modules with
// every link between them as the design wires it, and the rest as ports
// for test/ooe/trio_tb.cpp to drive from the model. Not a block: a bench
// top, so the per-module benches' frames meet in one clock.
//
// The links: ooe_sched's grant register to ooe_rs's issued register and
// ooe_wake's timers (their own copies); ooe_rs's matrix, line selects and
// valid bits to ooe_sched, and the matrix to ooe_wake's confirmation;
// ooe_wake's lines, leads, issued bits, held misses and miss pulses to
// ooe_sched, and its final bits, held misses and model-frame lead to
// ooe_rs's confirmation. ooe_rs and ooe_wake share the completion channel,
// the registered squash's frees and its lead.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST trio_rst
module ooe_trio #(
  parameter int N  = 45,
  parameter int NR = 30,
  parameter int A  = 4,
  parameter int NC = 4,
  parameter int S  = 4,
  parameter int FB = 1,
  parameter logic [63:0] LAT  = 64'h0000_050c_0000_0703,
  parameter logic [63:0] FAST = 64'h0000_0000_0000_0400,
  parameter logic [23:0] PEN  = 24'h03_02_00,
  parameter int NPEN     = 3,
  parameter int LAT_COPY = 7,
  parameter int LAT_SPEC = 16,
  parameter int LAT_MISS = 19,
  parameter int CMPL_DLY = 1,
  localparam int P  = 2 * A,
  localparam int W  = $clog2(N),
  localparam int NM = N - NR,
  localparam int LS = $clog2(S)
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // Rename's rows (ooe_rs).
  input  logic [P-1:0]      req_l_cq00h,
  input  logic [P-1:0]      req_cq01h,
  input  logic [P-1:0]      row_prod_cq01h,
  input  logic [P*N-1:0]    row_dep_cq01h,
  input  logic [2*P*N-1:0]  row_code_cq01h,
  input  logic [P*P-1:0]    grp_dep_cq01h,
  input  logic [2*P*P-1:0]  grp_code_cq01h,
  input  logic [P*P-1:0]    prv_dep_cq01h,
  input  logic [2*P*P-1:0]  prv_code_cq01h,
  // The registered squash, the completion channel and its hints.
  input  logic [N-1:0]      sqf_cq01h,
  input  logic              sq_l_cq00h,
  input  logic [NC-1:0]     cmpl_l_cq00h,
  input  logic [NC*W-1:0]   cmpl_idx_cq00h,
  input  logic [NC-1:0]     hint_l_cq00h,
  input  logic [NC*W-1:0]   hint_idx_cq01h,
  // The RS payload ooe_wake's timers read at a grant.
  input  logic [2*N-1:0]    kind_cq01h,
  input  logic [3*N-1:0]    cls_cq01h,
  input  logic [N-1:0]      prod_cq01h,
  // ooe_sched's other terms.
  input  logic [N*LS-1:0]   slot_cq02h,
  input  logic [S-1:0]      active_cq02h,
  input  logic [N-1:0]      copy_cq02h,
  input  logic              alloc_cq02h,
  input  logic [N-1:0]      vel_cq03h,
  input  logic [N-1:0]      siss_cq03h,
  input  logic [N*N-1:0]    sdep_cq03h,
  input  logic [N*LS-1:0]   sslot_cq03h,
  input  logic [N*9-1:0]    res_cq03h,
  input  logic [N-1:0]      chas_cq03h,
  input  logic [N*W-1:0]    cidx_cq03h,
  input  logic [NR*NR-1:0]  older_r_cq03h,
  input  logic [NM*NM-1:0]  older_m_cq03h,
  input  logic [3:0]        busy_cq03h,
  input  logic [S-1:0]      block_cq03h,
  // A negative control (trio_tb's TRIO_CONTROL): 0 none, 1 no-msd (the
  // held misses never reach ooe_sched), 2 no-miss-lead (no event lead),
  // 3 late-leads (the miss pulses and held misses a cycle late, as flops of
  // their own would give them), 4 no-alloc-lead.
  input  logic [2:0]        ctl,
  // What the bench compares.
  output logic [N-1:0]      grant_cq04h,
  output logic [P-1:0]      gnt_v_cq03h,
  output logic [P*W-1:0]    gnt_idx_cq03h,
  output logic [N-1:0]      valid_cq02h,
  output logic [N*N-1:0]    dep_cq02h,
  output logic [4*N-1:0]    wake_cq02h,
  output logic [N-1:0]      iss_cq02h,
  output logic [N-1:0]      miss_cq02h,
  output logic [N-1:0]      fin_cq02h,
  output logic [N-1:0]      msd_cq02h
);
  logic [N-1:0]      grant_w;
  logic [2*N*N-1:0]  code;
  logic [N-1:0]      hcol;
  logic [4*N-1:0]    wtl;
  logic              wml;
  logic [N-1:0]      flt;
  logic [N-1:0]      prod_o;
  // ooe_wake takes the completion's payload a cycle after ooe_rs's stage
  // name for it; both are the channel's payload at the same edge.
  ooe_rs #(.N(N), .NR(NR), .A(A), .NC(NC)) u_rs (
    .ooe_core_clk(ooe_core_clk), .ooe_rst_r00h(ooe_rst_r00h),
    .req_l_cq00h(req_l_cq00h), .req_cq01h(req_cq01h), .row_prod_cq01h(row_prod_cq01h),
    .row_dep_cq01h(row_dep_cq01h), .row_code_cq01h(row_code_cq01h),
    .grp_dep_cq01h(grp_dep_cq01h), .grp_code_cq01h(grp_code_cq01h),
    .prv_dep_cq01h(prv_dep_cq01h), .prv_code_cq01h(prv_code_cq01h),
    .sqf_cq01h(sqf_cq01h), .msd_cq01h(msd_cq02h), .cfin_cq01h(fin_cq02h),
    .wtl3_cq00h(flt), .fin_cq00h(fin_cq02h), .gnt_cq01h(grant_cq04h),
    .cmpl_l_cq00h(cmpl_l_cq00h), .cmpl_idx_cq00h(cmpl_idx_cq00h), .sq_l_cq00h(sq_l_cq00h),
    .gnt_v_cq03h(gnt_v_cq03h), .gnt_idx_cq03h(gnt_idx_cq03h), .valid_out_cq02h(valid_cq02h),
    .dep_cq02h(dep_cq02h), .code_cq02h(code), .prod_o_cq02h(prod_o), .hcol_cq02h(hcol));
  ooe_wake #(.N(N), .LAT(LAT), .FAST(FAST), .PEN(PEN), .NPEN(NPEN), .LAT_COPY(LAT_COPY),
             .LAT_SPEC(LAT_SPEC), .LAT_MISS(LAT_MISS), .CMPL_DLY(CMPL_DLY), .NC(NC)) u_wake (
    .ooe_core_clk(ooe_core_clk), .ooe_rst_r00h(ooe_rst_r00h),
    .grant_cq01h(grant_w), .kind_cq01h(kind_cq01h), .cls_cq01h(cls_cq01h), .prod_cq01h(prod_cq01h),
    .cmpl_l_cq00h(cmpl_l_cq00h), .cmpl_idx_cq01h(cmpl_idx_cq00h),
    .hint_l_cq00h(hint_l_cq00h), .hint_idx_cq01h(hint_idx_cq01h),
    .dep_cq01h(dep_cq02h), .sqf_cq01h(sqf_cq01h), .sq_l_cq00h(sq_l_cq00h),
    .wake_cq02h(wake_cq02h), .miss_cq02h(miss_cq02h), .fin_cq02h(fin_cq02h), .iss_cq02h(iss_cq02h),
    .msd_cq02h(msd_cq02h), .wtl_cq02h(wtl), .flt_cq02h(flt), .wml_cq02h(wml));
  // The control's view of what reaches ooe_sched.
  logic [N-1:0] msd_q, mis_q, s_msd, s_mis;
  logic         s_wml, s_alloc;
  always_ff @(posedge ooe_core_clk) begin
    msd_q <= msd_cq02h;
    mis_q <= miss_cq02h;
  end
  always_comb begin
    s_msd   = ctl == 3'd1 ? '0 : ctl == 3'd3 ? msd_q : msd_cq02h;
    s_mis   = ctl == 3'd3 ? mis_q : miss_cq02h;
    s_wml   = ctl == 3'd2 ? 1'b0 : wml;
    s_alloc = ctl == 3'd4 ? 1'b0 : alloc_cq02h;
  end
  // V-65 (OA's response OI-45 (1)): ooe_sched's issued after an edge,
  // formed from its own replay rule, is ooe_rs's issued register after
  // that edge, on every valid entry the edge does not free; except a grant
  // ooe_sched replays at its own edge (granted on a stale ready bit), which
  // ooe_rs takes as issued and replays at the next edge.
  logic         trio_rst;
  logic [N-1:0] ise_q, fre_q, gr_q, gr_q2;
  always_ff @(posedge ooe_core_clk) begin
    trio_rst <= ooe_rst_r00h;
    ise_q    <= u_sched.ise_cq02h;
    fre_q    <= u_rs.free_cq02h;
    gr_q     <= u_sched.gnt_cq04h & u_sched.rep_cq02h;
    gr_q2    <= gr_q;
  end
  `CCV_ASSERT(v65_issued, ctl != 3'd0 || ((ise_q ^ u_rs.iss_cq02h) & valid_cq02h & ~fre_q & ~gr_q) == '0)
  `CCV_ASSERT(v65_stale_grant, ctl != 3'd0 || (gr_q2 & u_rs.iss_cq02h & ~grant_cq04h) == '0)
  ooe_sched #(.N(N), .NR(NR), .S(S), .FB(FB)) u_sched (
    .ooe_core_clk(ooe_core_clk), .ooe_rst_r00h(ooe_rst_r00h),
    .dep_cq02h(dep_cq02h), .code_cq02h(code), .wake_cq02h(wake_cq02h), .valid_cq02h(valid_cq02h),
    .iss_cq02h(iss_cq02h), .slot_cq02h(slot_cq02h), .active_cq02h(active_cq02h), .copy_cq02h(copy_cq02h),
    .msd_cq02h(s_msd), .mis_cq02h(s_mis), .fin_cq02h(fin_cq02h), .prod_cq02h(prod_o), .wtl_cq02h(wtl), .wml_cq02h(s_wml),
    .alloc_cq02h(s_alloc),
    .vel_cq03h(vel_cq03h), .siss_cq03h(siss_cq03h), .sdep_cq03h(sdep_cq03h), .sslot_cq03h(sslot_cq03h),
    .res_cq03h(res_cq03h), .chas_cq03h(chas_cq03h), .cidx_cq03h(cidx_cq03h),
    .older_r_cq03h(older_r_cq03h), .older_m_cq03h(older_m_cq03h), .busy_cq03h(busy_cq03h),
    .block_cq03h(block_cq03h), .grant_cq04h(grant_cq04h), .grant_w_cq04h(grant_w));
endmodule
`undef CCV_CLK
`undef CCV_RST
