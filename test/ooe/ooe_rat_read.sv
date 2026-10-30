//===-- ooe_rat_read.sv - bench top: ooe_rat with Rename 1's RAT read ----===//
//
// Not a block: test/ooe/rat_tb.cpp's top. ooe_rat holds the maps and
// writes them; ooe_ratread, Rename 1's logic in ooe_rename (OA's response
// OI-46, reopened), reads them with the in-group override. Together they
// share rename's group fields: this cycle's, which the read takes, and
// last cycle's in rename's register, which ooe_rat writes at this edge and
// the read takes as pending (OA's response OI-58).
//===----------------------------------------------------------------------===//
module ooe_rat_read #(
  parameter int S  = 4,
  parameter int A  = 4,
  parameter int R  = 2,
  parameter int C  = 4,
  parameter int GW = 10,
  parameter int PW = 6,
  parameter logic [GW-1:0] GZERO = '1,
  parameter logic [PW-1:0] PZERO = '1,
  localparam int NG = 16,
  localparam int NP = 4,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LC = (C > 1) ? $clog2(C) : 1,
  localparam int MW = NG * GW + NP * PW
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // This cycle's group, as Rename 1 reads it.
  input  logic [A-1:0]      ren_v_cq01h,
  input  logic [A*LS-1:0]   ren_slot_cq01h,
  input  logic [A-1:0]      ren_rst_cq01h,
  input  logic [A*3*4-1:0]  ren_src_cq01h,
  input  logic [A*4-1:0]    ren_dst_cq01h,
  input  logic [A-1:0]      ren_gwe_cq01h,
  input  logic [A*GW-1:0]   ren_gname_cq01h,
  input  logic [A*2-1:0]    ren_pguard_cq01h,
  input  logic [A*2-1:0]    ren_pdst_cq01h,
  input  logic [A-1:0]      ren_pwe_cq01h,
  input  logic [A*PW-1:0]   ren_pname_cq01h,
  input  logic [A*2*2-1:0]  ren_pq_cq01h,
  output logic [A*3*GW-1:0] ren_psrc_cq01h,
  output logic [A*GW-1:0]   ren_pold_cq01h,
  output logic [A*PW-1:0]   ren_ppguard_cq01h,
  output logic [A*PW-1:0]   ren_ppold_cq01h,
  output logic [A*2*PW-1:0] ren_ppq_cq01h,
  // Its leads into ooe_rat.
  input  logic [S*A-1:0]    tk_cq00h,
  input  logic [S*A-1:0]    hbr_cq00h,
  input  logic [S*A*LC-1:0] hck_cq00h,
  input  logic [S-1:0]      rstl_cq00h,
  // Last cycle's group, which ooe_rat captures at this edge and writes at the next.
  input  logic [A-1:0]      pw_v_cq01h,
  input  logic [A*LS-1:0]   pw_slot_cq01h,
  input  logic [A-1:0]      pw_rst_cq01h,
  input  logic [A*4-1:0]    pw_dst_cq01h,
  input  logic [A-1:0]      pw_gwe_cq01h,
  input  logic [A*GW-1:0]   pw_gname_cq01h,
  input  logic [A*2-1:0]    pw_pdst_cq01h,
  input  logic [A-1:0]      pw_pwe_cq01h,
  input  logic [A*PW-1:0]   pw_pname_cq01h,
  input  logic [A-1:0]      pw_br_cq01h,
  input  logic [A*LC-1:0]   pw_ckpt_cq01h,
  input  logic [S*R-1:0]    rgl_cq00h,
  input  logic [S*R-1:0]    rpl_cq00h,
  input  logic [S*R-1:0]    ret_gwe_cq01h,
  input  logic [S*R*4-1:0]  ret_dst_cq01h,
  input  logic [S*R*GW-1:0] ret_gname_cq01h,
  input  logic [S*R-1:0]    ret_pwe_cq01h,
  input  logic [S*R*2-1:0]  ret_pdst_cq01h,
  input  logic [S*R*PW-1:0] ret_pname_cq01h,
  input  logic [S-1:0]      restore_cq00h,
  input  logic [S*LC-1:0]   restore_ckpt_cq00h,
  input  logic [S-1:0]      squash_cq00h,
  input  logic [S-1:0]      release_cq00h,
  output logic [S*MW-1:0]   rat_cq02h,
  output logic [S*MW-1:0]   crat_cq02h,
  output logic [S*C*MW-1:0] ckpt_cq02h,
  input  logic              ctl_pkeep          // ooe_rat's control pend-over-event
);
  // ooe_rat's capture of the group before last (OI-83 (b)), into the read.
  logic [A-1:0]      po_v_cq02h, po_gwe_cq02h, po_pwe_cq02h;
  logic [A*LS-1:0]   po_slot_cq02h;
  logic [A*4-1:0]    po_dst_cq02h;
  logic [A*GW-1:0]   po_gname_cq02h;
  logic [A*2-1:0]    po_pdst_cq02h;
  logic [A*PW-1:0]   po_pname_cq02h;
  ooe_rat #(.S(S), .A(A), .R(R), .C(C), .GW(GW), .PW(PW), .GZERO(GZERO), .PZERO(PZERO)) ooe_rat (
    .ooe_core_clk, .ooe_rst_r00h, .tk_cq00h, .hbr_cq00h, .hck_cq00h, .rstl_cq00h, .pw_v_cq01h, .pw_slot_cq01h,
    .pw_rst_cq01h, .pw_dst_cq01h, .pw_gwe_cq01h, .pw_gname_cq01h, .pw_pdst_cq01h, .pw_pwe_cq01h, .pw_pname_cq01h,
    .pw_br_cq01h, .pw_ckpt_cq01h, .rgl_cq00h, .rpl_cq00h, .ret_gwe_cq01h, .ret_dst_cq01h, .ret_gname_cq01h,
    .ret_pwe_cq01h, .ret_pdst_cq01h, .ret_pname_cq01h, .restore_cq00h, .restore_ckpt_cq00h, .squash_cq00h,
    .release_cq00h, .ctl_pkeep, .po_v_cq02h, .po_slot_cq02h, .po_dst_cq02h, .po_gwe_cq02h, .po_gname_cq02h,
    .po_pdst_cq02h, .po_pwe_cq02h, .po_pname_cq02h, .rat_cq02h, .crat_cq02h, .ckpt_cq02h);
  ooe_ratread #(.S(S), .A(A), .GW(GW), .PW(PW)) ooe_ratread (
    .rat_cq02h, .ren_v_cq01h, .ren_slot_cq01h, .ren_rst_cq01h, .ren_src_cq01h, .ren_dst_cq01h, .ren_gwe_cq01h,
    .ren_gname_cq01h, .ren_pguard_cq01h, .ren_pdst_cq01h, .ren_pwe_cq01h, .ren_pname_cq01h, .ren_pq_cq01h,
    .po_v_cq02h, .po_slot_cq02h, .po_dst_cq02h, .po_gwe_cq02h, .po_gname_cq02h, .po_pdst_cq02h, .po_pwe_cq02h,
    .po_pname_cq02h, .pw_v_cq01h, .pw_slot_cq01h, .pw_dst_cq01h, .pw_gwe_cq01h, .pw_gname_cq01h, .pw_pdst_cq01h,
    .pw_pwe_cq01h, .pw_pname_cq01h, .ren_psrc_cq01h, .ren_pold_cq01h, .ren_ppguard_cq01h, .ren_ppold_cq01h, .ren_ppq_cq01h);
endmodule
