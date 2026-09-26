// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// The CCV core: 45 block instances, 108 channel instances.
//
// Channel nets are flat, instance-major then slot -- the same order
// as the C++ skeleton's slot map, so the checker bank is fed by
// concatenation. tools/check-top.sh extracts this netlist's
// connectivity from Yosys and compares it, bit for bit, with the
// wiring the C++ skeleton reports.
//
// COMMON PORTS, by fabric (schema common_ports):
//   kill_valid / _warp_mask /    broadcast from RAU, the one true
//   _epoch                       broadcast, to the eight blocks that
//                                own warp state; kill_ack and its
//                                epoch gathered back at RAU
//   wake                         not a common port: each channel
//                                carries <name>_wake, sender to
//                                receiver
//   sleep_ok                     local: drives the block's own
//                                clock gate, nothing else
//   csr_*                        a star from CRU, which owns the
//                                CSR fabric; CRU's own csr ports
//                                are the host side, at this
//                                boundary
// rst_n fans out directly; the reset tree (block letter z) is not
// modelled yet.
//
// Block instance index (for the per-block common-port vectors):
//    0  u_fet
//    1  u_dec
//    2  u_ooe
//    3  u_rcu
//    4  u_lane_00
//    5  u_lane_01
//    6  u_lane_02
//    7  u_lane_03
//    8  u_lane_04
//    9  u_lane_05
//   10  u_lane_06
//   11  u_lane_07
//   12  u_lane_08
//   13  u_lane_09
//   14  u_lane_10
//   15  u_lane_11
//   16  u_lane_12
//   17  u_lane_13
//   18  u_lane_14
//   19  u_lane_15
//   20  u_lane_16
//   21  u_lane_17
//   22  u_lane_18
//   23  u_lane_19
//   24  u_lane_20
//   25  u_lane_21
//   26  u_lane_22
//   27  u_lane_23
//   28  u_lane_24
//   29  u_lane_25
//   30  u_lane_26
//   31  u_lane_27
//   32  u_lane_28
//   33  u_lane_29
//   34  u_lane_30
//   35  u_lane_31
//   36  u_miu
//   37  u_spm
//   38  u_dcu
//   39  u_mlc
//   40  u_rau
//   41  u_syu
//   42  u_pca
//   43  u_cru
//   44  u_exb
`include "ccv_interfaces.svh"

module ccv_core_top (
  input  logic core_clk,
  input  logic rst_n,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  output logic exb_ext_out_valid,
  output ccv_exb_ext_out_t exb_ext_out_payload,
  input  logic exb_ext_out_credit,
  input  logic exb_ext_out_stall,
  output logic exb_ext_out_wake,
  input  logic ext_exb_in_valid,
  input  ccv_ext_exb_in_t ext_exb_in_payload,
  output logic ext_exb_in_credit,
  output logic ext_exb_in_stall,
  input  logic ext_exb_in_wake
`ifdef CCV_TRACE
  , output logic [63:0] exb_ext_out_tid
  , input  logic [63:0] ext_exb_in_tid
`endif
);

  // Common-port fabrics.
  logic kill_valid;   // from rau
  logic [31:0] kill_warp_mask;   // from rau
  logic [1:0] kill_epoch;   // from rau
  logic [7:0] kill_ack;   // gathered at rau from fet, dec, ooe, rcu, miu, spm, syu, pca
  logic [15:0] kill_ack_epoch;   // gathered at rau from fet, dec, ooe, rcu, miu, spm, syu, pca
  /* verilator lint_off UNUSEDSIGNAL */
  logic [2204:0] csr_reqs;   // csr_req, star from cru
  /* verilator lint_on UNUSEDSIGNAL */
  logic [1484:0] csr_rsps;   // csr_rsp, star from cru
  logic [44:0] csr_credits;   // csr_credit, star from cru
  assign csr_rsps[1419 +: 33] = '0;   // u_cru's own: its host side is at the boundary
  assign csr_credits[43 +: 1] = '0;   // u_cru's own: its host side is at the boundary

  // ccv_fet_dec_instr: fet -> dec, 1 copy x 8 slots
  logic fet_dec_instr_s0_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s0_payload;
  logic fet_dec_instr_s0_credit;
  logic fet_dec_instr_s0_stall;
  logic fet_dec_instr_s1_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s1_payload;
  logic fet_dec_instr_s1_credit;
  logic fet_dec_instr_s1_stall;
  logic fet_dec_instr_s2_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s2_payload;
  logic fet_dec_instr_s2_credit;
  logic fet_dec_instr_s2_stall;
  logic fet_dec_instr_s3_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s3_payload;
  logic fet_dec_instr_s3_credit;
  logic fet_dec_instr_s3_stall;
  logic fet_dec_instr_s4_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s4_payload;
  logic fet_dec_instr_s4_credit;
  logic fet_dec_instr_s4_stall;
  logic fet_dec_instr_s5_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s5_payload;
  logic fet_dec_instr_s5_credit;
  logic fet_dec_instr_s5_stall;
  logic fet_dec_instr_s6_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s6_payload;
  logic fet_dec_instr_s6_credit;
  logic fet_dec_instr_s6_stall;
  logic fet_dec_instr_s7_valid;
  ccv_fet_dec_instr_t fet_dec_instr_s7_payload;
  logic fet_dec_instr_s7_credit;
  logic fet_dec_instr_s7_stall;
  logic fet_dec_instr_wake;
`ifdef CCV_TRACE
  logic [63:0] fet_dec_instr_s0_tid;
  logic [63:0] fet_dec_instr_s1_tid;
  logic [63:0] fet_dec_instr_s2_tid;
  logic [63:0] fet_dec_instr_s3_tid;
  logic [63:0] fet_dec_instr_s4_tid;
  logic [63:0] fet_dec_instr_s5_tid;
  logic [63:0] fet_dec_instr_s6_tid;
  logic [63:0] fet_dec_instr_s7_tid;
`endif
  // ccv_dec_ooe_uop: dec -> ooe, 1 copy x 6 slots
  logic dec_ooe_uop_s0_valid;
  ccv_dec_ooe_uop_t dec_ooe_uop_s0_payload;
  logic dec_ooe_uop_s0_credit;
  logic dec_ooe_uop_s0_stall;
  logic dec_ooe_uop_s1_valid;
  ccv_dec_ooe_uop_t dec_ooe_uop_s1_payload;
  logic dec_ooe_uop_s1_credit;
  logic dec_ooe_uop_s1_stall;
  logic dec_ooe_uop_s2_valid;
  ccv_dec_ooe_uop_t dec_ooe_uop_s2_payload;
  logic dec_ooe_uop_s2_credit;
  logic dec_ooe_uop_s2_stall;
  logic dec_ooe_uop_s3_valid;
  ccv_dec_ooe_uop_t dec_ooe_uop_s3_payload;
  logic dec_ooe_uop_s3_credit;
  logic dec_ooe_uop_s3_stall;
  logic dec_ooe_uop_s4_valid;
  ccv_dec_ooe_uop_t dec_ooe_uop_s4_payload;
  logic dec_ooe_uop_s4_credit;
  logic dec_ooe_uop_s4_stall;
  logic dec_ooe_uop_s5_valid;
  ccv_dec_ooe_uop_t dec_ooe_uop_s5_payload;
  logic dec_ooe_uop_s5_credit;
  logic dec_ooe_uop_s5_stall;
  logic dec_ooe_uop_wake;
`ifdef CCV_TRACE
  logic [63:0] dec_ooe_uop_s0_tid;
  logic [63:0] dec_ooe_uop_s1_tid;
  logic [63:0] dec_ooe_uop_s2_tid;
  logic [63:0] dec_ooe_uop_s3_tid;
  logic [63:0] dec_ooe_uop_s4_tid;
  logic [63:0] dec_ooe_uop_s5_tid;
`endif
  // ccv_ooe_rcu_issue: ooe -> rcu, 1 copy x 4 slots
  logic ooe_rcu_issue_s0_valid;
  ccv_ooe_rcu_issue_t ooe_rcu_issue_s0_payload;
  logic ooe_rcu_issue_s0_credit;
  logic ooe_rcu_issue_s0_stall;
  logic ooe_rcu_issue_s1_valid;
  ccv_ooe_rcu_issue_t ooe_rcu_issue_s1_payload;
  logic ooe_rcu_issue_s1_credit;
  logic ooe_rcu_issue_s1_stall;
  logic ooe_rcu_issue_s2_valid;
  ccv_ooe_rcu_issue_t ooe_rcu_issue_s2_payload;
  logic ooe_rcu_issue_s2_credit;
  logic ooe_rcu_issue_s2_stall;
  logic ooe_rcu_issue_s3_valid;
  ccv_ooe_rcu_issue_t ooe_rcu_issue_s3_payload;
  logic ooe_rcu_issue_s3_credit;
  logic ooe_rcu_issue_s3_stall;
  logic ooe_rcu_issue_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_rcu_issue_s0_tid;
  logic [63:0] ooe_rcu_issue_s1_tid;
  logic [63:0] ooe_rcu_issue_s2_tid;
  logic [63:0] ooe_rcu_issue_s3_tid;
`endif
  // ccv_rcu_lane_ops: rcu -> lane, 32 copies x 4 slots
  logic rcu_lane_ops_c00_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c00_s0_payload;
  logic rcu_lane_ops_c00_s0_credit;
  logic rcu_lane_ops_c00_s0_stall;
  logic rcu_lane_ops_c00_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c00_s1_payload;
  logic rcu_lane_ops_c00_s1_credit;
  logic rcu_lane_ops_c00_s1_stall;
  logic rcu_lane_ops_c00_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c00_s2_payload;
  logic rcu_lane_ops_c00_s2_credit;
  logic rcu_lane_ops_c00_s2_stall;
  logic rcu_lane_ops_c00_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c00_s3_payload;
  logic rcu_lane_ops_c00_s3_credit;
  logic rcu_lane_ops_c00_s3_stall;
  logic rcu_lane_ops_c00_wake;
  logic rcu_lane_ops_c01_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c01_s0_payload;
  logic rcu_lane_ops_c01_s0_credit;
  logic rcu_lane_ops_c01_s0_stall;
  logic rcu_lane_ops_c01_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c01_s1_payload;
  logic rcu_lane_ops_c01_s1_credit;
  logic rcu_lane_ops_c01_s1_stall;
  logic rcu_lane_ops_c01_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c01_s2_payload;
  logic rcu_lane_ops_c01_s2_credit;
  logic rcu_lane_ops_c01_s2_stall;
  logic rcu_lane_ops_c01_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c01_s3_payload;
  logic rcu_lane_ops_c01_s3_credit;
  logic rcu_lane_ops_c01_s3_stall;
  logic rcu_lane_ops_c01_wake;
  logic rcu_lane_ops_c02_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c02_s0_payload;
  logic rcu_lane_ops_c02_s0_credit;
  logic rcu_lane_ops_c02_s0_stall;
  logic rcu_lane_ops_c02_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c02_s1_payload;
  logic rcu_lane_ops_c02_s1_credit;
  logic rcu_lane_ops_c02_s1_stall;
  logic rcu_lane_ops_c02_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c02_s2_payload;
  logic rcu_lane_ops_c02_s2_credit;
  logic rcu_lane_ops_c02_s2_stall;
  logic rcu_lane_ops_c02_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c02_s3_payload;
  logic rcu_lane_ops_c02_s3_credit;
  logic rcu_lane_ops_c02_s3_stall;
  logic rcu_lane_ops_c02_wake;
  logic rcu_lane_ops_c03_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c03_s0_payload;
  logic rcu_lane_ops_c03_s0_credit;
  logic rcu_lane_ops_c03_s0_stall;
  logic rcu_lane_ops_c03_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c03_s1_payload;
  logic rcu_lane_ops_c03_s1_credit;
  logic rcu_lane_ops_c03_s1_stall;
  logic rcu_lane_ops_c03_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c03_s2_payload;
  logic rcu_lane_ops_c03_s2_credit;
  logic rcu_lane_ops_c03_s2_stall;
  logic rcu_lane_ops_c03_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c03_s3_payload;
  logic rcu_lane_ops_c03_s3_credit;
  logic rcu_lane_ops_c03_s3_stall;
  logic rcu_lane_ops_c03_wake;
  logic rcu_lane_ops_c04_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c04_s0_payload;
  logic rcu_lane_ops_c04_s0_credit;
  logic rcu_lane_ops_c04_s0_stall;
  logic rcu_lane_ops_c04_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c04_s1_payload;
  logic rcu_lane_ops_c04_s1_credit;
  logic rcu_lane_ops_c04_s1_stall;
  logic rcu_lane_ops_c04_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c04_s2_payload;
  logic rcu_lane_ops_c04_s2_credit;
  logic rcu_lane_ops_c04_s2_stall;
  logic rcu_lane_ops_c04_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c04_s3_payload;
  logic rcu_lane_ops_c04_s3_credit;
  logic rcu_lane_ops_c04_s3_stall;
  logic rcu_lane_ops_c04_wake;
  logic rcu_lane_ops_c05_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c05_s0_payload;
  logic rcu_lane_ops_c05_s0_credit;
  logic rcu_lane_ops_c05_s0_stall;
  logic rcu_lane_ops_c05_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c05_s1_payload;
  logic rcu_lane_ops_c05_s1_credit;
  logic rcu_lane_ops_c05_s1_stall;
  logic rcu_lane_ops_c05_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c05_s2_payload;
  logic rcu_lane_ops_c05_s2_credit;
  logic rcu_lane_ops_c05_s2_stall;
  logic rcu_lane_ops_c05_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c05_s3_payload;
  logic rcu_lane_ops_c05_s3_credit;
  logic rcu_lane_ops_c05_s3_stall;
  logic rcu_lane_ops_c05_wake;
  logic rcu_lane_ops_c06_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c06_s0_payload;
  logic rcu_lane_ops_c06_s0_credit;
  logic rcu_lane_ops_c06_s0_stall;
  logic rcu_lane_ops_c06_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c06_s1_payload;
  logic rcu_lane_ops_c06_s1_credit;
  logic rcu_lane_ops_c06_s1_stall;
  logic rcu_lane_ops_c06_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c06_s2_payload;
  logic rcu_lane_ops_c06_s2_credit;
  logic rcu_lane_ops_c06_s2_stall;
  logic rcu_lane_ops_c06_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c06_s3_payload;
  logic rcu_lane_ops_c06_s3_credit;
  logic rcu_lane_ops_c06_s3_stall;
  logic rcu_lane_ops_c06_wake;
  logic rcu_lane_ops_c07_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c07_s0_payload;
  logic rcu_lane_ops_c07_s0_credit;
  logic rcu_lane_ops_c07_s0_stall;
  logic rcu_lane_ops_c07_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c07_s1_payload;
  logic rcu_lane_ops_c07_s1_credit;
  logic rcu_lane_ops_c07_s1_stall;
  logic rcu_lane_ops_c07_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c07_s2_payload;
  logic rcu_lane_ops_c07_s2_credit;
  logic rcu_lane_ops_c07_s2_stall;
  logic rcu_lane_ops_c07_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c07_s3_payload;
  logic rcu_lane_ops_c07_s3_credit;
  logic rcu_lane_ops_c07_s3_stall;
  logic rcu_lane_ops_c07_wake;
  logic rcu_lane_ops_c08_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c08_s0_payload;
  logic rcu_lane_ops_c08_s0_credit;
  logic rcu_lane_ops_c08_s0_stall;
  logic rcu_lane_ops_c08_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c08_s1_payload;
  logic rcu_lane_ops_c08_s1_credit;
  logic rcu_lane_ops_c08_s1_stall;
  logic rcu_lane_ops_c08_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c08_s2_payload;
  logic rcu_lane_ops_c08_s2_credit;
  logic rcu_lane_ops_c08_s2_stall;
  logic rcu_lane_ops_c08_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c08_s3_payload;
  logic rcu_lane_ops_c08_s3_credit;
  logic rcu_lane_ops_c08_s3_stall;
  logic rcu_lane_ops_c08_wake;
  logic rcu_lane_ops_c09_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c09_s0_payload;
  logic rcu_lane_ops_c09_s0_credit;
  logic rcu_lane_ops_c09_s0_stall;
  logic rcu_lane_ops_c09_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c09_s1_payload;
  logic rcu_lane_ops_c09_s1_credit;
  logic rcu_lane_ops_c09_s1_stall;
  logic rcu_lane_ops_c09_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c09_s2_payload;
  logic rcu_lane_ops_c09_s2_credit;
  logic rcu_lane_ops_c09_s2_stall;
  logic rcu_lane_ops_c09_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c09_s3_payload;
  logic rcu_lane_ops_c09_s3_credit;
  logic rcu_lane_ops_c09_s3_stall;
  logic rcu_lane_ops_c09_wake;
  logic rcu_lane_ops_c10_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c10_s0_payload;
  logic rcu_lane_ops_c10_s0_credit;
  logic rcu_lane_ops_c10_s0_stall;
  logic rcu_lane_ops_c10_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c10_s1_payload;
  logic rcu_lane_ops_c10_s1_credit;
  logic rcu_lane_ops_c10_s1_stall;
  logic rcu_lane_ops_c10_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c10_s2_payload;
  logic rcu_lane_ops_c10_s2_credit;
  logic rcu_lane_ops_c10_s2_stall;
  logic rcu_lane_ops_c10_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c10_s3_payload;
  logic rcu_lane_ops_c10_s3_credit;
  logic rcu_lane_ops_c10_s3_stall;
  logic rcu_lane_ops_c10_wake;
  logic rcu_lane_ops_c11_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c11_s0_payload;
  logic rcu_lane_ops_c11_s0_credit;
  logic rcu_lane_ops_c11_s0_stall;
  logic rcu_lane_ops_c11_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c11_s1_payload;
  logic rcu_lane_ops_c11_s1_credit;
  logic rcu_lane_ops_c11_s1_stall;
  logic rcu_lane_ops_c11_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c11_s2_payload;
  logic rcu_lane_ops_c11_s2_credit;
  logic rcu_lane_ops_c11_s2_stall;
  logic rcu_lane_ops_c11_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c11_s3_payload;
  logic rcu_lane_ops_c11_s3_credit;
  logic rcu_lane_ops_c11_s3_stall;
  logic rcu_lane_ops_c11_wake;
  logic rcu_lane_ops_c12_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c12_s0_payload;
  logic rcu_lane_ops_c12_s0_credit;
  logic rcu_lane_ops_c12_s0_stall;
  logic rcu_lane_ops_c12_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c12_s1_payload;
  logic rcu_lane_ops_c12_s1_credit;
  logic rcu_lane_ops_c12_s1_stall;
  logic rcu_lane_ops_c12_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c12_s2_payload;
  logic rcu_lane_ops_c12_s2_credit;
  logic rcu_lane_ops_c12_s2_stall;
  logic rcu_lane_ops_c12_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c12_s3_payload;
  logic rcu_lane_ops_c12_s3_credit;
  logic rcu_lane_ops_c12_s3_stall;
  logic rcu_lane_ops_c12_wake;
  logic rcu_lane_ops_c13_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c13_s0_payload;
  logic rcu_lane_ops_c13_s0_credit;
  logic rcu_lane_ops_c13_s0_stall;
  logic rcu_lane_ops_c13_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c13_s1_payload;
  logic rcu_lane_ops_c13_s1_credit;
  logic rcu_lane_ops_c13_s1_stall;
  logic rcu_lane_ops_c13_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c13_s2_payload;
  logic rcu_lane_ops_c13_s2_credit;
  logic rcu_lane_ops_c13_s2_stall;
  logic rcu_lane_ops_c13_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c13_s3_payload;
  logic rcu_lane_ops_c13_s3_credit;
  logic rcu_lane_ops_c13_s3_stall;
  logic rcu_lane_ops_c13_wake;
  logic rcu_lane_ops_c14_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c14_s0_payload;
  logic rcu_lane_ops_c14_s0_credit;
  logic rcu_lane_ops_c14_s0_stall;
  logic rcu_lane_ops_c14_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c14_s1_payload;
  logic rcu_lane_ops_c14_s1_credit;
  logic rcu_lane_ops_c14_s1_stall;
  logic rcu_lane_ops_c14_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c14_s2_payload;
  logic rcu_lane_ops_c14_s2_credit;
  logic rcu_lane_ops_c14_s2_stall;
  logic rcu_lane_ops_c14_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c14_s3_payload;
  logic rcu_lane_ops_c14_s3_credit;
  logic rcu_lane_ops_c14_s3_stall;
  logic rcu_lane_ops_c14_wake;
  logic rcu_lane_ops_c15_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c15_s0_payload;
  logic rcu_lane_ops_c15_s0_credit;
  logic rcu_lane_ops_c15_s0_stall;
  logic rcu_lane_ops_c15_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c15_s1_payload;
  logic rcu_lane_ops_c15_s1_credit;
  logic rcu_lane_ops_c15_s1_stall;
  logic rcu_lane_ops_c15_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c15_s2_payload;
  logic rcu_lane_ops_c15_s2_credit;
  logic rcu_lane_ops_c15_s2_stall;
  logic rcu_lane_ops_c15_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c15_s3_payload;
  logic rcu_lane_ops_c15_s3_credit;
  logic rcu_lane_ops_c15_s3_stall;
  logic rcu_lane_ops_c15_wake;
  logic rcu_lane_ops_c16_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c16_s0_payload;
  logic rcu_lane_ops_c16_s0_credit;
  logic rcu_lane_ops_c16_s0_stall;
  logic rcu_lane_ops_c16_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c16_s1_payload;
  logic rcu_lane_ops_c16_s1_credit;
  logic rcu_lane_ops_c16_s1_stall;
  logic rcu_lane_ops_c16_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c16_s2_payload;
  logic rcu_lane_ops_c16_s2_credit;
  logic rcu_lane_ops_c16_s2_stall;
  logic rcu_lane_ops_c16_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c16_s3_payload;
  logic rcu_lane_ops_c16_s3_credit;
  logic rcu_lane_ops_c16_s3_stall;
  logic rcu_lane_ops_c16_wake;
  logic rcu_lane_ops_c17_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c17_s0_payload;
  logic rcu_lane_ops_c17_s0_credit;
  logic rcu_lane_ops_c17_s0_stall;
  logic rcu_lane_ops_c17_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c17_s1_payload;
  logic rcu_lane_ops_c17_s1_credit;
  logic rcu_lane_ops_c17_s1_stall;
  logic rcu_lane_ops_c17_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c17_s2_payload;
  logic rcu_lane_ops_c17_s2_credit;
  logic rcu_lane_ops_c17_s2_stall;
  logic rcu_lane_ops_c17_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c17_s3_payload;
  logic rcu_lane_ops_c17_s3_credit;
  logic rcu_lane_ops_c17_s3_stall;
  logic rcu_lane_ops_c17_wake;
  logic rcu_lane_ops_c18_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c18_s0_payload;
  logic rcu_lane_ops_c18_s0_credit;
  logic rcu_lane_ops_c18_s0_stall;
  logic rcu_lane_ops_c18_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c18_s1_payload;
  logic rcu_lane_ops_c18_s1_credit;
  logic rcu_lane_ops_c18_s1_stall;
  logic rcu_lane_ops_c18_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c18_s2_payload;
  logic rcu_lane_ops_c18_s2_credit;
  logic rcu_lane_ops_c18_s2_stall;
  logic rcu_lane_ops_c18_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c18_s3_payload;
  logic rcu_lane_ops_c18_s3_credit;
  logic rcu_lane_ops_c18_s3_stall;
  logic rcu_lane_ops_c18_wake;
  logic rcu_lane_ops_c19_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c19_s0_payload;
  logic rcu_lane_ops_c19_s0_credit;
  logic rcu_lane_ops_c19_s0_stall;
  logic rcu_lane_ops_c19_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c19_s1_payload;
  logic rcu_lane_ops_c19_s1_credit;
  logic rcu_lane_ops_c19_s1_stall;
  logic rcu_lane_ops_c19_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c19_s2_payload;
  logic rcu_lane_ops_c19_s2_credit;
  logic rcu_lane_ops_c19_s2_stall;
  logic rcu_lane_ops_c19_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c19_s3_payload;
  logic rcu_lane_ops_c19_s3_credit;
  logic rcu_lane_ops_c19_s3_stall;
  logic rcu_lane_ops_c19_wake;
  logic rcu_lane_ops_c20_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c20_s0_payload;
  logic rcu_lane_ops_c20_s0_credit;
  logic rcu_lane_ops_c20_s0_stall;
  logic rcu_lane_ops_c20_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c20_s1_payload;
  logic rcu_lane_ops_c20_s1_credit;
  logic rcu_lane_ops_c20_s1_stall;
  logic rcu_lane_ops_c20_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c20_s2_payload;
  logic rcu_lane_ops_c20_s2_credit;
  logic rcu_lane_ops_c20_s2_stall;
  logic rcu_lane_ops_c20_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c20_s3_payload;
  logic rcu_lane_ops_c20_s3_credit;
  logic rcu_lane_ops_c20_s3_stall;
  logic rcu_lane_ops_c20_wake;
  logic rcu_lane_ops_c21_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c21_s0_payload;
  logic rcu_lane_ops_c21_s0_credit;
  logic rcu_lane_ops_c21_s0_stall;
  logic rcu_lane_ops_c21_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c21_s1_payload;
  logic rcu_lane_ops_c21_s1_credit;
  logic rcu_lane_ops_c21_s1_stall;
  logic rcu_lane_ops_c21_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c21_s2_payload;
  logic rcu_lane_ops_c21_s2_credit;
  logic rcu_lane_ops_c21_s2_stall;
  logic rcu_lane_ops_c21_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c21_s3_payload;
  logic rcu_lane_ops_c21_s3_credit;
  logic rcu_lane_ops_c21_s3_stall;
  logic rcu_lane_ops_c21_wake;
  logic rcu_lane_ops_c22_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c22_s0_payload;
  logic rcu_lane_ops_c22_s0_credit;
  logic rcu_lane_ops_c22_s0_stall;
  logic rcu_lane_ops_c22_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c22_s1_payload;
  logic rcu_lane_ops_c22_s1_credit;
  logic rcu_lane_ops_c22_s1_stall;
  logic rcu_lane_ops_c22_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c22_s2_payload;
  logic rcu_lane_ops_c22_s2_credit;
  logic rcu_lane_ops_c22_s2_stall;
  logic rcu_lane_ops_c22_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c22_s3_payload;
  logic rcu_lane_ops_c22_s3_credit;
  logic rcu_lane_ops_c22_s3_stall;
  logic rcu_lane_ops_c22_wake;
  logic rcu_lane_ops_c23_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c23_s0_payload;
  logic rcu_lane_ops_c23_s0_credit;
  logic rcu_lane_ops_c23_s0_stall;
  logic rcu_lane_ops_c23_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c23_s1_payload;
  logic rcu_lane_ops_c23_s1_credit;
  logic rcu_lane_ops_c23_s1_stall;
  logic rcu_lane_ops_c23_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c23_s2_payload;
  logic rcu_lane_ops_c23_s2_credit;
  logic rcu_lane_ops_c23_s2_stall;
  logic rcu_lane_ops_c23_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c23_s3_payload;
  logic rcu_lane_ops_c23_s3_credit;
  logic rcu_lane_ops_c23_s3_stall;
  logic rcu_lane_ops_c23_wake;
  logic rcu_lane_ops_c24_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c24_s0_payload;
  logic rcu_lane_ops_c24_s0_credit;
  logic rcu_lane_ops_c24_s0_stall;
  logic rcu_lane_ops_c24_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c24_s1_payload;
  logic rcu_lane_ops_c24_s1_credit;
  logic rcu_lane_ops_c24_s1_stall;
  logic rcu_lane_ops_c24_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c24_s2_payload;
  logic rcu_lane_ops_c24_s2_credit;
  logic rcu_lane_ops_c24_s2_stall;
  logic rcu_lane_ops_c24_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c24_s3_payload;
  logic rcu_lane_ops_c24_s3_credit;
  logic rcu_lane_ops_c24_s3_stall;
  logic rcu_lane_ops_c24_wake;
  logic rcu_lane_ops_c25_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c25_s0_payload;
  logic rcu_lane_ops_c25_s0_credit;
  logic rcu_lane_ops_c25_s0_stall;
  logic rcu_lane_ops_c25_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c25_s1_payload;
  logic rcu_lane_ops_c25_s1_credit;
  logic rcu_lane_ops_c25_s1_stall;
  logic rcu_lane_ops_c25_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c25_s2_payload;
  logic rcu_lane_ops_c25_s2_credit;
  logic rcu_lane_ops_c25_s2_stall;
  logic rcu_lane_ops_c25_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c25_s3_payload;
  logic rcu_lane_ops_c25_s3_credit;
  logic rcu_lane_ops_c25_s3_stall;
  logic rcu_lane_ops_c25_wake;
  logic rcu_lane_ops_c26_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c26_s0_payload;
  logic rcu_lane_ops_c26_s0_credit;
  logic rcu_lane_ops_c26_s0_stall;
  logic rcu_lane_ops_c26_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c26_s1_payload;
  logic rcu_lane_ops_c26_s1_credit;
  logic rcu_lane_ops_c26_s1_stall;
  logic rcu_lane_ops_c26_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c26_s2_payload;
  logic rcu_lane_ops_c26_s2_credit;
  logic rcu_lane_ops_c26_s2_stall;
  logic rcu_lane_ops_c26_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c26_s3_payload;
  logic rcu_lane_ops_c26_s3_credit;
  logic rcu_lane_ops_c26_s3_stall;
  logic rcu_lane_ops_c26_wake;
  logic rcu_lane_ops_c27_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c27_s0_payload;
  logic rcu_lane_ops_c27_s0_credit;
  logic rcu_lane_ops_c27_s0_stall;
  logic rcu_lane_ops_c27_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c27_s1_payload;
  logic rcu_lane_ops_c27_s1_credit;
  logic rcu_lane_ops_c27_s1_stall;
  logic rcu_lane_ops_c27_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c27_s2_payload;
  logic rcu_lane_ops_c27_s2_credit;
  logic rcu_lane_ops_c27_s2_stall;
  logic rcu_lane_ops_c27_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c27_s3_payload;
  logic rcu_lane_ops_c27_s3_credit;
  logic rcu_lane_ops_c27_s3_stall;
  logic rcu_lane_ops_c27_wake;
  logic rcu_lane_ops_c28_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c28_s0_payload;
  logic rcu_lane_ops_c28_s0_credit;
  logic rcu_lane_ops_c28_s0_stall;
  logic rcu_lane_ops_c28_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c28_s1_payload;
  logic rcu_lane_ops_c28_s1_credit;
  logic rcu_lane_ops_c28_s1_stall;
  logic rcu_lane_ops_c28_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c28_s2_payload;
  logic rcu_lane_ops_c28_s2_credit;
  logic rcu_lane_ops_c28_s2_stall;
  logic rcu_lane_ops_c28_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c28_s3_payload;
  logic rcu_lane_ops_c28_s3_credit;
  logic rcu_lane_ops_c28_s3_stall;
  logic rcu_lane_ops_c28_wake;
  logic rcu_lane_ops_c29_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c29_s0_payload;
  logic rcu_lane_ops_c29_s0_credit;
  logic rcu_lane_ops_c29_s0_stall;
  logic rcu_lane_ops_c29_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c29_s1_payload;
  logic rcu_lane_ops_c29_s1_credit;
  logic rcu_lane_ops_c29_s1_stall;
  logic rcu_lane_ops_c29_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c29_s2_payload;
  logic rcu_lane_ops_c29_s2_credit;
  logic rcu_lane_ops_c29_s2_stall;
  logic rcu_lane_ops_c29_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c29_s3_payload;
  logic rcu_lane_ops_c29_s3_credit;
  logic rcu_lane_ops_c29_s3_stall;
  logic rcu_lane_ops_c29_wake;
  logic rcu_lane_ops_c30_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c30_s0_payload;
  logic rcu_lane_ops_c30_s0_credit;
  logic rcu_lane_ops_c30_s0_stall;
  logic rcu_lane_ops_c30_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c30_s1_payload;
  logic rcu_lane_ops_c30_s1_credit;
  logic rcu_lane_ops_c30_s1_stall;
  logic rcu_lane_ops_c30_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c30_s2_payload;
  logic rcu_lane_ops_c30_s2_credit;
  logic rcu_lane_ops_c30_s2_stall;
  logic rcu_lane_ops_c30_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c30_s3_payload;
  logic rcu_lane_ops_c30_s3_credit;
  logic rcu_lane_ops_c30_s3_stall;
  logic rcu_lane_ops_c30_wake;
  logic rcu_lane_ops_c31_s0_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c31_s0_payload;
  logic rcu_lane_ops_c31_s0_credit;
  logic rcu_lane_ops_c31_s0_stall;
  logic rcu_lane_ops_c31_s1_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c31_s1_payload;
  logic rcu_lane_ops_c31_s1_credit;
  logic rcu_lane_ops_c31_s1_stall;
  logic rcu_lane_ops_c31_s2_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c31_s2_payload;
  logic rcu_lane_ops_c31_s2_credit;
  logic rcu_lane_ops_c31_s2_stall;
  logic rcu_lane_ops_c31_s3_valid;
  ccv_rcu_lane_ops_t rcu_lane_ops_c31_s3_payload;
  logic rcu_lane_ops_c31_s3_credit;
  logic rcu_lane_ops_c31_s3_stall;
  logic rcu_lane_ops_c31_wake;
`ifdef CCV_TRACE
  logic [63:0] rcu_lane_ops_c00_s0_tid;
  logic [63:0] rcu_lane_ops_c00_s1_tid;
  logic [63:0] rcu_lane_ops_c00_s2_tid;
  logic [63:0] rcu_lane_ops_c00_s3_tid;
  logic [63:0] rcu_lane_ops_c01_s0_tid;
  logic [63:0] rcu_lane_ops_c01_s1_tid;
  logic [63:0] rcu_lane_ops_c01_s2_tid;
  logic [63:0] rcu_lane_ops_c01_s3_tid;
  logic [63:0] rcu_lane_ops_c02_s0_tid;
  logic [63:0] rcu_lane_ops_c02_s1_tid;
  logic [63:0] rcu_lane_ops_c02_s2_tid;
  logic [63:0] rcu_lane_ops_c02_s3_tid;
  logic [63:0] rcu_lane_ops_c03_s0_tid;
  logic [63:0] rcu_lane_ops_c03_s1_tid;
  logic [63:0] rcu_lane_ops_c03_s2_tid;
  logic [63:0] rcu_lane_ops_c03_s3_tid;
  logic [63:0] rcu_lane_ops_c04_s0_tid;
  logic [63:0] rcu_lane_ops_c04_s1_tid;
  logic [63:0] rcu_lane_ops_c04_s2_tid;
  logic [63:0] rcu_lane_ops_c04_s3_tid;
  logic [63:0] rcu_lane_ops_c05_s0_tid;
  logic [63:0] rcu_lane_ops_c05_s1_tid;
  logic [63:0] rcu_lane_ops_c05_s2_tid;
  logic [63:0] rcu_lane_ops_c05_s3_tid;
  logic [63:0] rcu_lane_ops_c06_s0_tid;
  logic [63:0] rcu_lane_ops_c06_s1_tid;
  logic [63:0] rcu_lane_ops_c06_s2_tid;
  logic [63:0] rcu_lane_ops_c06_s3_tid;
  logic [63:0] rcu_lane_ops_c07_s0_tid;
  logic [63:0] rcu_lane_ops_c07_s1_tid;
  logic [63:0] rcu_lane_ops_c07_s2_tid;
  logic [63:0] rcu_lane_ops_c07_s3_tid;
  logic [63:0] rcu_lane_ops_c08_s0_tid;
  logic [63:0] rcu_lane_ops_c08_s1_tid;
  logic [63:0] rcu_lane_ops_c08_s2_tid;
  logic [63:0] rcu_lane_ops_c08_s3_tid;
  logic [63:0] rcu_lane_ops_c09_s0_tid;
  logic [63:0] rcu_lane_ops_c09_s1_tid;
  logic [63:0] rcu_lane_ops_c09_s2_tid;
  logic [63:0] rcu_lane_ops_c09_s3_tid;
  logic [63:0] rcu_lane_ops_c10_s0_tid;
  logic [63:0] rcu_lane_ops_c10_s1_tid;
  logic [63:0] rcu_lane_ops_c10_s2_tid;
  logic [63:0] rcu_lane_ops_c10_s3_tid;
  logic [63:0] rcu_lane_ops_c11_s0_tid;
  logic [63:0] rcu_lane_ops_c11_s1_tid;
  logic [63:0] rcu_lane_ops_c11_s2_tid;
  logic [63:0] rcu_lane_ops_c11_s3_tid;
  logic [63:0] rcu_lane_ops_c12_s0_tid;
  logic [63:0] rcu_lane_ops_c12_s1_tid;
  logic [63:0] rcu_lane_ops_c12_s2_tid;
  logic [63:0] rcu_lane_ops_c12_s3_tid;
  logic [63:0] rcu_lane_ops_c13_s0_tid;
  logic [63:0] rcu_lane_ops_c13_s1_tid;
  logic [63:0] rcu_lane_ops_c13_s2_tid;
  logic [63:0] rcu_lane_ops_c13_s3_tid;
  logic [63:0] rcu_lane_ops_c14_s0_tid;
  logic [63:0] rcu_lane_ops_c14_s1_tid;
  logic [63:0] rcu_lane_ops_c14_s2_tid;
  logic [63:0] rcu_lane_ops_c14_s3_tid;
  logic [63:0] rcu_lane_ops_c15_s0_tid;
  logic [63:0] rcu_lane_ops_c15_s1_tid;
  logic [63:0] rcu_lane_ops_c15_s2_tid;
  logic [63:0] rcu_lane_ops_c15_s3_tid;
  logic [63:0] rcu_lane_ops_c16_s0_tid;
  logic [63:0] rcu_lane_ops_c16_s1_tid;
  logic [63:0] rcu_lane_ops_c16_s2_tid;
  logic [63:0] rcu_lane_ops_c16_s3_tid;
  logic [63:0] rcu_lane_ops_c17_s0_tid;
  logic [63:0] rcu_lane_ops_c17_s1_tid;
  logic [63:0] rcu_lane_ops_c17_s2_tid;
  logic [63:0] rcu_lane_ops_c17_s3_tid;
  logic [63:0] rcu_lane_ops_c18_s0_tid;
  logic [63:0] rcu_lane_ops_c18_s1_tid;
  logic [63:0] rcu_lane_ops_c18_s2_tid;
  logic [63:0] rcu_lane_ops_c18_s3_tid;
  logic [63:0] rcu_lane_ops_c19_s0_tid;
  logic [63:0] rcu_lane_ops_c19_s1_tid;
  logic [63:0] rcu_lane_ops_c19_s2_tid;
  logic [63:0] rcu_lane_ops_c19_s3_tid;
  logic [63:0] rcu_lane_ops_c20_s0_tid;
  logic [63:0] rcu_lane_ops_c20_s1_tid;
  logic [63:0] rcu_lane_ops_c20_s2_tid;
  logic [63:0] rcu_lane_ops_c20_s3_tid;
  logic [63:0] rcu_lane_ops_c21_s0_tid;
  logic [63:0] rcu_lane_ops_c21_s1_tid;
  logic [63:0] rcu_lane_ops_c21_s2_tid;
  logic [63:0] rcu_lane_ops_c21_s3_tid;
  logic [63:0] rcu_lane_ops_c22_s0_tid;
  logic [63:0] rcu_lane_ops_c22_s1_tid;
  logic [63:0] rcu_lane_ops_c22_s2_tid;
  logic [63:0] rcu_lane_ops_c22_s3_tid;
  logic [63:0] rcu_lane_ops_c23_s0_tid;
  logic [63:0] rcu_lane_ops_c23_s1_tid;
  logic [63:0] rcu_lane_ops_c23_s2_tid;
  logic [63:0] rcu_lane_ops_c23_s3_tid;
  logic [63:0] rcu_lane_ops_c24_s0_tid;
  logic [63:0] rcu_lane_ops_c24_s1_tid;
  logic [63:0] rcu_lane_ops_c24_s2_tid;
  logic [63:0] rcu_lane_ops_c24_s3_tid;
  logic [63:0] rcu_lane_ops_c25_s0_tid;
  logic [63:0] rcu_lane_ops_c25_s1_tid;
  logic [63:0] rcu_lane_ops_c25_s2_tid;
  logic [63:0] rcu_lane_ops_c25_s3_tid;
  logic [63:0] rcu_lane_ops_c26_s0_tid;
  logic [63:0] rcu_lane_ops_c26_s1_tid;
  logic [63:0] rcu_lane_ops_c26_s2_tid;
  logic [63:0] rcu_lane_ops_c26_s3_tid;
  logic [63:0] rcu_lane_ops_c27_s0_tid;
  logic [63:0] rcu_lane_ops_c27_s1_tid;
  logic [63:0] rcu_lane_ops_c27_s2_tid;
  logic [63:0] rcu_lane_ops_c27_s3_tid;
  logic [63:0] rcu_lane_ops_c28_s0_tid;
  logic [63:0] rcu_lane_ops_c28_s1_tid;
  logic [63:0] rcu_lane_ops_c28_s2_tid;
  logic [63:0] rcu_lane_ops_c28_s3_tid;
  logic [63:0] rcu_lane_ops_c29_s0_tid;
  logic [63:0] rcu_lane_ops_c29_s1_tid;
  logic [63:0] rcu_lane_ops_c29_s2_tid;
  logic [63:0] rcu_lane_ops_c29_s3_tid;
  logic [63:0] rcu_lane_ops_c30_s0_tid;
  logic [63:0] rcu_lane_ops_c30_s1_tid;
  logic [63:0] rcu_lane_ops_c30_s2_tid;
  logic [63:0] rcu_lane_ops_c30_s3_tid;
  logic [63:0] rcu_lane_ops_c31_s0_tid;
  logic [63:0] rcu_lane_ops_c31_s1_tid;
  logic [63:0] rcu_lane_ops_c31_s2_tid;
  logic [63:0] rcu_lane_ops_c31_s3_tid;
`endif
  // ccv_lane_rcu_res: lane -> rcu, 32 copies x 4 slots
  logic lane_rcu_res_c00_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c00_s0_payload;
  logic lane_rcu_res_c00_s0_credit;
  logic lane_rcu_res_c00_s0_stall;
  logic lane_rcu_res_c00_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c00_s1_payload;
  logic lane_rcu_res_c00_s1_credit;
  logic lane_rcu_res_c00_s1_stall;
  logic lane_rcu_res_c00_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c00_s2_payload;
  logic lane_rcu_res_c00_s2_credit;
  logic lane_rcu_res_c00_s2_stall;
  logic lane_rcu_res_c00_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c00_s3_payload;
  logic lane_rcu_res_c00_s3_credit;
  logic lane_rcu_res_c00_s3_stall;
  logic lane_rcu_res_c00_wake;
  logic lane_rcu_res_c01_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c01_s0_payload;
  logic lane_rcu_res_c01_s0_credit;
  logic lane_rcu_res_c01_s0_stall;
  logic lane_rcu_res_c01_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c01_s1_payload;
  logic lane_rcu_res_c01_s1_credit;
  logic lane_rcu_res_c01_s1_stall;
  logic lane_rcu_res_c01_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c01_s2_payload;
  logic lane_rcu_res_c01_s2_credit;
  logic lane_rcu_res_c01_s2_stall;
  logic lane_rcu_res_c01_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c01_s3_payload;
  logic lane_rcu_res_c01_s3_credit;
  logic lane_rcu_res_c01_s3_stall;
  logic lane_rcu_res_c01_wake;
  logic lane_rcu_res_c02_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c02_s0_payload;
  logic lane_rcu_res_c02_s0_credit;
  logic lane_rcu_res_c02_s0_stall;
  logic lane_rcu_res_c02_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c02_s1_payload;
  logic lane_rcu_res_c02_s1_credit;
  logic lane_rcu_res_c02_s1_stall;
  logic lane_rcu_res_c02_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c02_s2_payload;
  logic lane_rcu_res_c02_s2_credit;
  logic lane_rcu_res_c02_s2_stall;
  logic lane_rcu_res_c02_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c02_s3_payload;
  logic lane_rcu_res_c02_s3_credit;
  logic lane_rcu_res_c02_s3_stall;
  logic lane_rcu_res_c02_wake;
  logic lane_rcu_res_c03_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c03_s0_payload;
  logic lane_rcu_res_c03_s0_credit;
  logic lane_rcu_res_c03_s0_stall;
  logic lane_rcu_res_c03_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c03_s1_payload;
  logic lane_rcu_res_c03_s1_credit;
  logic lane_rcu_res_c03_s1_stall;
  logic lane_rcu_res_c03_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c03_s2_payload;
  logic lane_rcu_res_c03_s2_credit;
  logic lane_rcu_res_c03_s2_stall;
  logic lane_rcu_res_c03_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c03_s3_payload;
  logic lane_rcu_res_c03_s3_credit;
  logic lane_rcu_res_c03_s3_stall;
  logic lane_rcu_res_c03_wake;
  logic lane_rcu_res_c04_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c04_s0_payload;
  logic lane_rcu_res_c04_s0_credit;
  logic lane_rcu_res_c04_s0_stall;
  logic lane_rcu_res_c04_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c04_s1_payload;
  logic lane_rcu_res_c04_s1_credit;
  logic lane_rcu_res_c04_s1_stall;
  logic lane_rcu_res_c04_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c04_s2_payload;
  logic lane_rcu_res_c04_s2_credit;
  logic lane_rcu_res_c04_s2_stall;
  logic lane_rcu_res_c04_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c04_s3_payload;
  logic lane_rcu_res_c04_s3_credit;
  logic lane_rcu_res_c04_s3_stall;
  logic lane_rcu_res_c04_wake;
  logic lane_rcu_res_c05_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c05_s0_payload;
  logic lane_rcu_res_c05_s0_credit;
  logic lane_rcu_res_c05_s0_stall;
  logic lane_rcu_res_c05_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c05_s1_payload;
  logic lane_rcu_res_c05_s1_credit;
  logic lane_rcu_res_c05_s1_stall;
  logic lane_rcu_res_c05_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c05_s2_payload;
  logic lane_rcu_res_c05_s2_credit;
  logic lane_rcu_res_c05_s2_stall;
  logic lane_rcu_res_c05_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c05_s3_payload;
  logic lane_rcu_res_c05_s3_credit;
  logic lane_rcu_res_c05_s3_stall;
  logic lane_rcu_res_c05_wake;
  logic lane_rcu_res_c06_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c06_s0_payload;
  logic lane_rcu_res_c06_s0_credit;
  logic lane_rcu_res_c06_s0_stall;
  logic lane_rcu_res_c06_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c06_s1_payload;
  logic lane_rcu_res_c06_s1_credit;
  logic lane_rcu_res_c06_s1_stall;
  logic lane_rcu_res_c06_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c06_s2_payload;
  logic lane_rcu_res_c06_s2_credit;
  logic lane_rcu_res_c06_s2_stall;
  logic lane_rcu_res_c06_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c06_s3_payload;
  logic lane_rcu_res_c06_s3_credit;
  logic lane_rcu_res_c06_s3_stall;
  logic lane_rcu_res_c06_wake;
  logic lane_rcu_res_c07_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c07_s0_payload;
  logic lane_rcu_res_c07_s0_credit;
  logic lane_rcu_res_c07_s0_stall;
  logic lane_rcu_res_c07_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c07_s1_payload;
  logic lane_rcu_res_c07_s1_credit;
  logic lane_rcu_res_c07_s1_stall;
  logic lane_rcu_res_c07_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c07_s2_payload;
  logic lane_rcu_res_c07_s2_credit;
  logic lane_rcu_res_c07_s2_stall;
  logic lane_rcu_res_c07_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c07_s3_payload;
  logic lane_rcu_res_c07_s3_credit;
  logic lane_rcu_res_c07_s3_stall;
  logic lane_rcu_res_c07_wake;
  logic lane_rcu_res_c08_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c08_s0_payload;
  logic lane_rcu_res_c08_s0_credit;
  logic lane_rcu_res_c08_s0_stall;
  logic lane_rcu_res_c08_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c08_s1_payload;
  logic lane_rcu_res_c08_s1_credit;
  logic lane_rcu_res_c08_s1_stall;
  logic lane_rcu_res_c08_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c08_s2_payload;
  logic lane_rcu_res_c08_s2_credit;
  logic lane_rcu_res_c08_s2_stall;
  logic lane_rcu_res_c08_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c08_s3_payload;
  logic lane_rcu_res_c08_s3_credit;
  logic lane_rcu_res_c08_s3_stall;
  logic lane_rcu_res_c08_wake;
  logic lane_rcu_res_c09_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c09_s0_payload;
  logic lane_rcu_res_c09_s0_credit;
  logic lane_rcu_res_c09_s0_stall;
  logic lane_rcu_res_c09_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c09_s1_payload;
  logic lane_rcu_res_c09_s1_credit;
  logic lane_rcu_res_c09_s1_stall;
  logic lane_rcu_res_c09_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c09_s2_payload;
  logic lane_rcu_res_c09_s2_credit;
  logic lane_rcu_res_c09_s2_stall;
  logic lane_rcu_res_c09_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c09_s3_payload;
  logic lane_rcu_res_c09_s3_credit;
  logic lane_rcu_res_c09_s3_stall;
  logic lane_rcu_res_c09_wake;
  logic lane_rcu_res_c10_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c10_s0_payload;
  logic lane_rcu_res_c10_s0_credit;
  logic lane_rcu_res_c10_s0_stall;
  logic lane_rcu_res_c10_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c10_s1_payload;
  logic lane_rcu_res_c10_s1_credit;
  logic lane_rcu_res_c10_s1_stall;
  logic lane_rcu_res_c10_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c10_s2_payload;
  logic lane_rcu_res_c10_s2_credit;
  logic lane_rcu_res_c10_s2_stall;
  logic lane_rcu_res_c10_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c10_s3_payload;
  logic lane_rcu_res_c10_s3_credit;
  logic lane_rcu_res_c10_s3_stall;
  logic lane_rcu_res_c10_wake;
  logic lane_rcu_res_c11_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c11_s0_payload;
  logic lane_rcu_res_c11_s0_credit;
  logic lane_rcu_res_c11_s0_stall;
  logic lane_rcu_res_c11_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c11_s1_payload;
  logic lane_rcu_res_c11_s1_credit;
  logic lane_rcu_res_c11_s1_stall;
  logic lane_rcu_res_c11_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c11_s2_payload;
  logic lane_rcu_res_c11_s2_credit;
  logic lane_rcu_res_c11_s2_stall;
  logic lane_rcu_res_c11_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c11_s3_payload;
  logic lane_rcu_res_c11_s3_credit;
  logic lane_rcu_res_c11_s3_stall;
  logic lane_rcu_res_c11_wake;
  logic lane_rcu_res_c12_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c12_s0_payload;
  logic lane_rcu_res_c12_s0_credit;
  logic lane_rcu_res_c12_s0_stall;
  logic lane_rcu_res_c12_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c12_s1_payload;
  logic lane_rcu_res_c12_s1_credit;
  logic lane_rcu_res_c12_s1_stall;
  logic lane_rcu_res_c12_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c12_s2_payload;
  logic lane_rcu_res_c12_s2_credit;
  logic lane_rcu_res_c12_s2_stall;
  logic lane_rcu_res_c12_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c12_s3_payload;
  logic lane_rcu_res_c12_s3_credit;
  logic lane_rcu_res_c12_s3_stall;
  logic lane_rcu_res_c12_wake;
  logic lane_rcu_res_c13_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c13_s0_payload;
  logic lane_rcu_res_c13_s0_credit;
  logic lane_rcu_res_c13_s0_stall;
  logic lane_rcu_res_c13_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c13_s1_payload;
  logic lane_rcu_res_c13_s1_credit;
  logic lane_rcu_res_c13_s1_stall;
  logic lane_rcu_res_c13_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c13_s2_payload;
  logic lane_rcu_res_c13_s2_credit;
  logic lane_rcu_res_c13_s2_stall;
  logic lane_rcu_res_c13_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c13_s3_payload;
  logic lane_rcu_res_c13_s3_credit;
  logic lane_rcu_res_c13_s3_stall;
  logic lane_rcu_res_c13_wake;
  logic lane_rcu_res_c14_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c14_s0_payload;
  logic lane_rcu_res_c14_s0_credit;
  logic lane_rcu_res_c14_s0_stall;
  logic lane_rcu_res_c14_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c14_s1_payload;
  logic lane_rcu_res_c14_s1_credit;
  logic lane_rcu_res_c14_s1_stall;
  logic lane_rcu_res_c14_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c14_s2_payload;
  logic lane_rcu_res_c14_s2_credit;
  logic lane_rcu_res_c14_s2_stall;
  logic lane_rcu_res_c14_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c14_s3_payload;
  logic lane_rcu_res_c14_s3_credit;
  logic lane_rcu_res_c14_s3_stall;
  logic lane_rcu_res_c14_wake;
  logic lane_rcu_res_c15_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c15_s0_payload;
  logic lane_rcu_res_c15_s0_credit;
  logic lane_rcu_res_c15_s0_stall;
  logic lane_rcu_res_c15_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c15_s1_payload;
  logic lane_rcu_res_c15_s1_credit;
  logic lane_rcu_res_c15_s1_stall;
  logic lane_rcu_res_c15_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c15_s2_payload;
  logic lane_rcu_res_c15_s2_credit;
  logic lane_rcu_res_c15_s2_stall;
  logic lane_rcu_res_c15_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c15_s3_payload;
  logic lane_rcu_res_c15_s3_credit;
  logic lane_rcu_res_c15_s3_stall;
  logic lane_rcu_res_c15_wake;
  logic lane_rcu_res_c16_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c16_s0_payload;
  logic lane_rcu_res_c16_s0_credit;
  logic lane_rcu_res_c16_s0_stall;
  logic lane_rcu_res_c16_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c16_s1_payload;
  logic lane_rcu_res_c16_s1_credit;
  logic lane_rcu_res_c16_s1_stall;
  logic lane_rcu_res_c16_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c16_s2_payload;
  logic lane_rcu_res_c16_s2_credit;
  logic lane_rcu_res_c16_s2_stall;
  logic lane_rcu_res_c16_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c16_s3_payload;
  logic lane_rcu_res_c16_s3_credit;
  logic lane_rcu_res_c16_s3_stall;
  logic lane_rcu_res_c16_wake;
  logic lane_rcu_res_c17_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c17_s0_payload;
  logic lane_rcu_res_c17_s0_credit;
  logic lane_rcu_res_c17_s0_stall;
  logic lane_rcu_res_c17_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c17_s1_payload;
  logic lane_rcu_res_c17_s1_credit;
  logic lane_rcu_res_c17_s1_stall;
  logic lane_rcu_res_c17_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c17_s2_payload;
  logic lane_rcu_res_c17_s2_credit;
  logic lane_rcu_res_c17_s2_stall;
  logic lane_rcu_res_c17_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c17_s3_payload;
  logic lane_rcu_res_c17_s3_credit;
  logic lane_rcu_res_c17_s3_stall;
  logic lane_rcu_res_c17_wake;
  logic lane_rcu_res_c18_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c18_s0_payload;
  logic lane_rcu_res_c18_s0_credit;
  logic lane_rcu_res_c18_s0_stall;
  logic lane_rcu_res_c18_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c18_s1_payload;
  logic lane_rcu_res_c18_s1_credit;
  logic lane_rcu_res_c18_s1_stall;
  logic lane_rcu_res_c18_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c18_s2_payload;
  logic lane_rcu_res_c18_s2_credit;
  logic lane_rcu_res_c18_s2_stall;
  logic lane_rcu_res_c18_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c18_s3_payload;
  logic lane_rcu_res_c18_s3_credit;
  logic lane_rcu_res_c18_s3_stall;
  logic lane_rcu_res_c18_wake;
  logic lane_rcu_res_c19_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c19_s0_payload;
  logic lane_rcu_res_c19_s0_credit;
  logic lane_rcu_res_c19_s0_stall;
  logic lane_rcu_res_c19_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c19_s1_payload;
  logic lane_rcu_res_c19_s1_credit;
  logic lane_rcu_res_c19_s1_stall;
  logic lane_rcu_res_c19_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c19_s2_payload;
  logic lane_rcu_res_c19_s2_credit;
  logic lane_rcu_res_c19_s2_stall;
  logic lane_rcu_res_c19_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c19_s3_payload;
  logic lane_rcu_res_c19_s3_credit;
  logic lane_rcu_res_c19_s3_stall;
  logic lane_rcu_res_c19_wake;
  logic lane_rcu_res_c20_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c20_s0_payload;
  logic lane_rcu_res_c20_s0_credit;
  logic lane_rcu_res_c20_s0_stall;
  logic lane_rcu_res_c20_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c20_s1_payload;
  logic lane_rcu_res_c20_s1_credit;
  logic lane_rcu_res_c20_s1_stall;
  logic lane_rcu_res_c20_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c20_s2_payload;
  logic lane_rcu_res_c20_s2_credit;
  logic lane_rcu_res_c20_s2_stall;
  logic lane_rcu_res_c20_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c20_s3_payload;
  logic lane_rcu_res_c20_s3_credit;
  logic lane_rcu_res_c20_s3_stall;
  logic lane_rcu_res_c20_wake;
  logic lane_rcu_res_c21_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c21_s0_payload;
  logic lane_rcu_res_c21_s0_credit;
  logic lane_rcu_res_c21_s0_stall;
  logic lane_rcu_res_c21_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c21_s1_payload;
  logic lane_rcu_res_c21_s1_credit;
  logic lane_rcu_res_c21_s1_stall;
  logic lane_rcu_res_c21_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c21_s2_payload;
  logic lane_rcu_res_c21_s2_credit;
  logic lane_rcu_res_c21_s2_stall;
  logic lane_rcu_res_c21_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c21_s3_payload;
  logic lane_rcu_res_c21_s3_credit;
  logic lane_rcu_res_c21_s3_stall;
  logic lane_rcu_res_c21_wake;
  logic lane_rcu_res_c22_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c22_s0_payload;
  logic lane_rcu_res_c22_s0_credit;
  logic lane_rcu_res_c22_s0_stall;
  logic lane_rcu_res_c22_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c22_s1_payload;
  logic lane_rcu_res_c22_s1_credit;
  logic lane_rcu_res_c22_s1_stall;
  logic lane_rcu_res_c22_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c22_s2_payload;
  logic lane_rcu_res_c22_s2_credit;
  logic lane_rcu_res_c22_s2_stall;
  logic lane_rcu_res_c22_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c22_s3_payload;
  logic lane_rcu_res_c22_s3_credit;
  logic lane_rcu_res_c22_s3_stall;
  logic lane_rcu_res_c22_wake;
  logic lane_rcu_res_c23_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c23_s0_payload;
  logic lane_rcu_res_c23_s0_credit;
  logic lane_rcu_res_c23_s0_stall;
  logic lane_rcu_res_c23_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c23_s1_payload;
  logic lane_rcu_res_c23_s1_credit;
  logic lane_rcu_res_c23_s1_stall;
  logic lane_rcu_res_c23_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c23_s2_payload;
  logic lane_rcu_res_c23_s2_credit;
  logic lane_rcu_res_c23_s2_stall;
  logic lane_rcu_res_c23_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c23_s3_payload;
  logic lane_rcu_res_c23_s3_credit;
  logic lane_rcu_res_c23_s3_stall;
  logic lane_rcu_res_c23_wake;
  logic lane_rcu_res_c24_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c24_s0_payload;
  logic lane_rcu_res_c24_s0_credit;
  logic lane_rcu_res_c24_s0_stall;
  logic lane_rcu_res_c24_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c24_s1_payload;
  logic lane_rcu_res_c24_s1_credit;
  logic lane_rcu_res_c24_s1_stall;
  logic lane_rcu_res_c24_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c24_s2_payload;
  logic lane_rcu_res_c24_s2_credit;
  logic lane_rcu_res_c24_s2_stall;
  logic lane_rcu_res_c24_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c24_s3_payload;
  logic lane_rcu_res_c24_s3_credit;
  logic lane_rcu_res_c24_s3_stall;
  logic lane_rcu_res_c24_wake;
  logic lane_rcu_res_c25_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c25_s0_payload;
  logic lane_rcu_res_c25_s0_credit;
  logic lane_rcu_res_c25_s0_stall;
  logic lane_rcu_res_c25_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c25_s1_payload;
  logic lane_rcu_res_c25_s1_credit;
  logic lane_rcu_res_c25_s1_stall;
  logic lane_rcu_res_c25_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c25_s2_payload;
  logic lane_rcu_res_c25_s2_credit;
  logic lane_rcu_res_c25_s2_stall;
  logic lane_rcu_res_c25_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c25_s3_payload;
  logic lane_rcu_res_c25_s3_credit;
  logic lane_rcu_res_c25_s3_stall;
  logic lane_rcu_res_c25_wake;
  logic lane_rcu_res_c26_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c26_s0_payload;
  logic lane_rcu_res_c26_s0_credit;
  logic lane_rcu_res_c26_s0_stall;
  logic lane_rcu_res_c26_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c26_s1_payload;
  logic lane_rcu_res_c26_s1_credit;
  logic lane_rcu_res_c26_s1_stall;
  logic lane_rcu_res_c26_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c26_s2_payload;
  logic lane_rcu_res_c26_s2_credit;
  logic lane_rcu_res_c26_s2_stall;
  logic lane_rcu_res_c26_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c26_s3_payload;
  logic lane_rcu_res_c26_s3_credit;
  logic lane_rcu_res_c26_s3_stall;
  logic lane_rcu_res_c26_wake;
  logic lane_rcu_res_c27_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c27_s0_payload;
  logic lane_rcu_res_c27_s0_credit;
  logic lane_rcu_res_c27_s0_stall;
  logic lane_rcu_res_c27_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c27_s1_payload;
  logic lane_rcu_res_c27_s1_credit;
  logic lane_rcu_res_c27_s1_stall;
  logic lane_rcu_res_c27_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c27_s2_payload;
  logic lane_rcu_res_c27_s2_credit;
  logic lane_rcu_res_c27_s2_stall;
  logic lane_rcu_res_c27_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c27_s3_payload;
  logic lane_rcu_res_c27_s3_credit;
  logic lane_rcu_res_c27_s3_stall;
  logic lane_rcu_res_c27_wake;
  logic lane_rcu_res_c28_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c28_s0_payload;
  logic lane_rcu_res_c28_s0_credit;
  logic lane_rcu_res_c28_s0_stall;
  logic lane_rcu_res_c28_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c28_s1_payload;
  logic lane_rcu_res_c28_s1_credit;
  logic lane_rcu_res_c28_s1_stall;
  logic lane_rcu_res_c28_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c28_s2_payload;
  logic lane_rcu_res_c28_s2_credit;
  logic lane_rcu_res_c28_s2_stall;
  logic lane_rcu_res_c28_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c28_s3_payload;
  logic lane_rcu_res_c28_s3_credit;
  logic lane_rcu_res_c28_s3_stall;
  logic lane_rcu_res_c28_wake;
  logic lane_rcu_res_c29_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c29_s0_payload;
  logic lane_rcu_res_c29_s0_credit;
  logic lane_rcu_res_c29_s0_stall;
  logic lane_rcu_res_c29_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c29_s1_payload;
  logic lane_rcu_res_c29_s1_credit;
  logic lane_rcu_res_c29_s1_stall;
  logic lane_rcu_res_c29_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c29_s2_payload;
  logic lane_rcu_res_c29_s2_credit;
  logic lane_rcu_res_c29_s2_stall;
  logic lane_rcu_res_c29_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c29_s3_payload;
  logic lane_rcu_res_c29_s3_credit;
  logic lane_rcu_res_c29_s3_stall;
  logic lane_rcu_res_c29_wake;
  logic lane_rcu_res_c30_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c30_s0_payload;
  logic lane_rcu_res_c30_s0_credit;
  logic lane_rcu_res_c30_s0_stall;
  logic lane_rcu_res_c30_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c30_s1_payload;
  logic lane_rcu_res_c30_s1_credit;
  logic lane_rcu_res_c30_s1_stall;
  logic lane_rcu_res_c30_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c30_s2_payload;
  logic lane_rcu_res_c30_s2_credit;
  logic lane_rcu_res_c30_s2_stall;
  logic lane_rcu_res_c30_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c30_s3_payload;
  logic lane_rcu_res_c30_s3_credit;
  logic lane_rcu_res_c30_s3_stall;
  logic lane_rcu_res_c30_wake;
  logic lane_rcu_res_c31_s0_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c31_s0_payload;
  logic lane_rcu_res_c31_s0_credit;
  logic lane_rcu_res_c31_s0_stall;
  logic lane_rcu_res_c31_s1_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c31_s1_payload;
  logic lane_rcu_res_c31_s1_credit;
  logic lane_rcu_res_c31_s1_stall;
  logic lane_rcu_res_c31_s2_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c31_s2_payload;
  logic lane_rcu_res_c31_s2_credit;
  logic lane_rcu_res_c31_s2_stall;
  logic lane_rcu_res_c31_s3_valid;
  ccv_lane_rcu_res_t lane_rcu_res_c31_s3_payload;
  logic lane_rcu_res_c31_s3_credit;
  logic lane_rcu_res_c31_s3_stall;
  logic lane_rcu_res_c31_wake;
`ifdef CCV_TRACE
  logic [63:0] lane_rcu_res_c00_s0_tid;
  logic [63:0] lane_rcu_res_c00_s1_tid;
  logic [63:0] lane_rcu_res_c00_s2_tid;
  logic [63:0] lane_rcu_res_c00_s3_tid;
  logic [63:0] lane_rcu_res_c01_s0_tid;
  logic [63:0] lane_rcu_res_c01_s1_tid;
  logic [63:0] lane_rcu_res_c01_s2_tid;
  logic [63:0] lane_rcu_res_c01_s3_tid;
  logic [63:0] lane_rcu_res_c02_s0_tid;
  logic [63:0] lane_rcu_res_c02_s1_tid;
  logic [63:0] lane_rcu_res_c02_s2_tid;
  logic [63:0] lane_rcu_res_c02_s3_tid;
  logic [63:0] lane_rcu_res_c03_s0_tid;
  logic [63:0] lane_rcu_res_c03_s1_tid;
  logic [63:0] lane_rcu_res_c03_s2_tid;
  logic [63:0] lane_rcu_res_c03_s3_tid;
  logic [63:0] lane_rcu_res_c04_s0_tid;
  logic [63:0] lane_rcu_res_c04_s1_tid;
  logic [63:0] lane_rcu_res_c04_s2_tid;
  logic [63:0] lane_rcu_res_c04_s3_tid;
  logic [63:0] lane_rcu_res_c05_s0_tid;
  logic [63:0] lane_rcu_res_c05_s1_tid;
  logic [63:0] lane_rcu_res_c05_s2_tid;
  logic [63:0] lane_rcu_res_c05_s3_tid;
  logic [63:0] lane_rcu_res_c06_s0_tid;
  logic [63:0] lane_rcu_res_c06_s1_tid;
  logic [63:0] lane_rcu_res_c06_s2_tid;
  logic [63:0] lane_rcu_res_c06_s3_tid;
  logic [63:0] lane_rcu_res_c07_s0_tid;
  logic [63:0] lane_rcu_res_c07_s1_tid;
  logic [63:0] lane_rcu_res_c07_s2_tid;
  logic [63:0] lane_rcu_res_c07_s3_tid;
  logic [63:0] lane_rcu_res_c08_s0_tid;
  logic [63:0] lane_rcu_res_c08_s1_tid;
  logic [63:0] lane_rcu_res_c08_s2_tid;
  logic [63:0] lane_rcu_res_c08_s3_tid;
  logic [63:0] lane_rcu_res_c09_s0_tid;
  logic [63:0] lane_rcu_res_c09_s1_tid;
  logic [63:0] lane_rcu_res_c09_s2_tid;
  logic [63:0] lane_rcu_res_c09_s3_tid;
  logic [63:0] lane_rcu_res_c10_s0_tid;
  logic [63:0] lane_rcu_res_c10_s1_tid;
  logic [63:0] lane_rcu_res_c10_s2_tid;
  logic [63:0] lane_rcu_res_c10_s3_tid;
  logic [63:0] lane_rcu_res_c11_s0_tid;
  logic [63:0] lane_rcu_res_c11_s1_tid;
  logic [63:0] lane_rcu_res_c11_s2_tid;
  logic [63:0] lane_rcu_res_c11_s3_tid;
  logic [63:0] lane_rcu_res_c12_s0_tid;
  logic [63:0] lane_rcu_res_c12_s1_tid;
  logic [63:0] lane_rcu_res_c12_s2_tid;
  logic [63:0] lane_rcu_res_c12_s3_tid;
  logic [63:0] lane_rcu_res_c13_s0_tid;
  logic [63:0] lane_rcu_res_c13_s1_tid;
  logic [63:0] lane_rcu_res_c13_s2_tid;
  logic [63:0] lane_rcu_res_c13_s3_tid;
  logic [63:0] lane_rcu_res_c14_s0_tid;
  logic [63:0] lane_rcu_res_c14_s1_tid;
  logic [63:0] lane_rcu_res_c14_s2_tid;
  logic [63:0] lane_rcu_res_c14_s3_tid;
  logic [63:0] lane_rcu_res_c15_s0_tid;
  logic [63:0] lane_rcu_res_c15_s1_tid;
  logic [63:0] lane_rcu_res_c15_s2_tid;
  logic [63:0] lane_rcu_res_c15_s3_tid;
  logic [63:0] lane_rcu_res_c16_s0_tid;
  logic [63:0] lane_rcu_res_c16_s1_tid;
  logic [63:0] lane_rcu_res_c16_s2_tid;
  logic [63:0] lane_rcu_res_c16_s3_tid;
  logic [63:0] lane_rcu_res_c17_s0_tid;
  logic [63:0] lane_rcu_res_c17_s1_tid;
  logic [63:0] lane_rcu_res_c17_s2_tid;
  logic [63:0] lane_rcu_res_c17_s3_tid;
  logic [63:0] lane_rcu_res_c18_s0_tid;
  logic [63:0] lane_rcu_res_c18_s1_tid;
  logic [63:0] lane_rcu_res_c18_s2_tid;
  logic [63:0] lane_rcu_res_c18_s3_tid;
  logic [63:0] lane_rcu_res_c19_s0_tid;
  logic [63:0] lane_rcu_res_c19_s1_tid;
  logic [63:0] lane_rcu_res_c19_s2_tid;
  logic [63:0] lane_rcu_res_c19_s3_tid;
  logic [63:0] lane_rcu_res_c20_s0_tid;
  logic [63:0] lane_rcu_res_c20_s1_tid;
  logic [63:0] lane_rcu_res_c20_s2_tid;
  logic [63:0] lane_rcu_res_c20_s3_tid;
  logic [63:0] lane_rcu_res_c21_s0_tid;
  logic [63:0] lane_rcu_res_c21_s1_tid;
  logic [63:0] lane_rcu_res_c21_s2_tid;
  logic [63:0] lane_rcu_res_c21_s3_tid;
  logic [63:0] lane_rcu_res_c22_s0_tid;
  logic [63:0] lane_rcu_res_c22_s1_tid;
  logic [63:0] lane_rcu_res_c22_s2_tid;
  logic [63:0] lane_rcu_res_c22_s3_tid;
  logic [63:0] lane_rcu_res_c23_s0_tid;
  logic [63:0] lane_rcu_res_c23_s1_tid;
  logic [63:0] lane_rcu_res_c23_s2_tid;
  logic [63:0] lane_rcu_res_c23_s3_tid;
  logic [63:0] lane_rcu_res_c24_s0_tid;
  logic [63:0] lane_rcu_res_c24_s1_tid;
  logic [63:0] lane_rcu_res_c24_s2_tid;
  logic [63:0] lane_rcu_res_c24_s3_tid;
  logic [63:0] lane_rcu_res_c25_s0_tid;
  logic [63:0] lane_rcu_res_c25_s1_tid;
  logic [63:0] lane_rcu_res_c25_s2_tid;
  logic [63:0] lane_rcu_res_c25_s3_tid;
  logic [63:0] lane_rcu_res_c26_s0_tid;
  logic [63:0] lane_rcu_res_c26_s1_tid;
  logic [63:0] lane_rcu_res_c26_s2_tid;
  logic [63:0] lane_rcu_res_c26_s3_tid;
  logic [63:0] lane_rcu_res_c27_s0_tid;
  logic [63:0] lane_rcu_res_c27_s1_tid;
  logic [63:0] lane_rcu_res_c27_s2_tid;
  logic [63:0] lane_rcu_res_c27_s3_tid;
  logic [63:0] lane_rcu_res_c28_s0_tid;
  logic [63:0] lane_rcu_res_c28_s1_tid;
  logic [63:0] lane_rcu_res_c28_s2_tid;
  logic [63:0] lane_rcu_res_c28_s3_tid;
  logic [63:0] lane_rcu_res_c29_s0_tid;
  logic [63:0] lane_rcu_res_c29_s1_tid;
  logic [63:0] lane_rcu_res_c29_s2_tid;
  logic [63:0] lane_rcu_res_c29_s3_tid;
  logic [63:0] lane_rcu_res_c30_s0_tid;
  logic [63:0] lane_rcu_res_c30_s1_tid;
  logic [63:0] lane_rcu_res_c30_s2_tid;
  logic [63:0] lane_rcu_res_c30_s3_tid;
  logic [63:0] lane_rcu_res_c31_s0_tid;
  logic [63:0] lane_rcu_res_c31_s1_tid;
  logic [63:0] lane_rcu_res_c31_s2_tid;
  logic [63:0] lane_rcu_res_c31_s3_tid;
`endif
  // ccv_rcu_ooe_done: rcu -> ooe, 1 copy x 4 slots
  logic rcu_ooe_done_s0_valid;
  ccv_rcu_ooe_done_t rcu_ooe_done_s0_payload;
  logic rcu_ooe_done_s0_credit;
  logic rcu_ooe_done_s0_stall;
  logic rcu_ooe_done_s1_valid;
  ccv_rcu_ooe_done_t rcu_ooe_done_s1_payload;
  logic rcu_ooe_done_s1_credit;
  logic rcu_ooe_done_s1_stall;
  logic rcu_ooe_done_s2_valid;
  ccv_rcu_ooe_done_t rcu_ooe_done_s2_payload;
  logic rcu_ooe_done_s2_credit;
  logic rcu_ooe_done_s2_stall;
  logic rcu_ooe_done_s3_valid;
  ccv_rcu_ooe_done_t rcu_ooe_done_s3_payload;
  logic rcu_ooe_done_s3_credit;
  logic rcu_ooe_done_s3_stall;
  logic rcu_ooe_done_wake;
`ifdef CCV_TRACE
  logic [63:0] rcu_ooe_done_s0_tid;
  logic [63:0] rcu_ooe_done_s1_tid;
  logic [63:0] rcu_ooe_done_s2_tid;
  logic [63:0] rcu_ooe_done_s3_tid;
`endif
  // ccv_rcu_miu_addr: rcu -> miu, 1 copy x 4 slots
  logic rcu_miu_addr_s0_valid;
  ccv_rcu_miu_addr_t rcu_miu_addr_s0_payload;
  logic rcu_miu_addr_s0_credit;
  logic rcu_miu_addr_s0_stall;
  logic rcu_miu_addr_s1_valid;
  ccv_rcu_miu_addr_t rcu_miu_addr_s1_payload;
  logic rcu_miu_addr_s1_credit;
  logic rcu_miu_addr_s1_stall;
  logic rcu_miu_addr_s2_valid;
  ccv_rcu_miu_addr_t rcu_miu_addr_s2_payload;
  logic rcu_miu_addr_s2_credit;
  logic rcu_miu_addr_s2_stall;
  logic rcu_miu_addr_s3_valid;
  ccv_rcu_miu_addr_t rcu_miu_addr_s3_payload;
  logic rcu_miu_addr_s3_credit;
  logic rcu_miu_addr_s3_stall;
  logic rcu_miu_addr_wake;
`ifdef CCV_TRACE
  logic [63:0] rcu_miu_addr_s0_tid;
  logic [63:0] rcu_miu_addr_s1_tid;
  logic [63:0] rcu_miu_addr_s2_tid;
  logic [63:0] rcu_miu_addr_s3_tid;
`endif
  // ccv_miu_rcu_data: miu -> rcu, 1 copy x 4 slots
  logic miu_rcu_data_s0_valid;
  ccv_miu_rcu_data_t miu_rcu_data_s0_payload;
  logic miu_rcu_data_s0_credit;
  logic miu_rcu_data_s0_stall;
  logic miu_rcu_data_s1_valid;
  ccv_miu_rcu_data_t miu_rcu_data_s1_payload;
  logic miu_rcu_data_s1_credit;
  logic miu_rcu_data_s1_stall;
  logic miu_rcu_data_s2_valid;
  ccv_miu_rcu_data_t miu_rcu_data_s2_payload;
  logic miu_rcu_data_s2_credit;
  logic miu_rcu_data_s2_stall;
  logic miu_rcu_data_s3_valid;
  ccv_miu_rcu_data_t miu_rcu_data_s3_payload;
  logic miu_rcu_data_s3_credit;
  logic miu_rcu_data_s3_stall;
  logic miu_rcu_data_wake;
`ifdef CCV_TRACE
  logic [63:0] miu_rcu_data_s0_tid;
  logic [63:0] miu_rcu_data_s1_tid;
  logic [63:0] miu_rcu_data_s2_tid;
  logic [63:0] miu_rcu_data_s3_tid;
`endif
  // ccv_ooe_miu_memop: ooe -> miu, 1 copy x 4 slots
  logic ooe_miu_memop_s0_valid;
  ccv_ooe_miu_memop_t ooe_miu_memop_s0_payload;
  logic ooe_miu_memop_s0_credit;
  logic ooe_miu_memop_s0_stall;
  logic ooe_miu_memop_s1_valid;
  ccv_ooe_miu_memop_t ooe_miu_memop_s1_payload;
  logic ooe_miu_memop_s1_credit;
  logic ooe_miu_memop_s1_stall;
  logic ooe_miu_memop_s2_valid;
  ccv_ooe_miu_memop_t ooe_miu_memop_s2_payload;
  logic ooe_miu_memop_s2_credit;
  logic ooe_miu_memop_s2_stall;
  logic ooe_miu_memop_s3_valid;
  ccv_ooe_miu_memop_t ooe_miu_memop_s3_payload;
  logic ooe_miu_memop_s3_credit;
  logic ooe_miu_memop_s3_stall;
  logic ooe_miu_memop_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_miu_memop_s0_tid;
  logic [63:0] ooe_miu_memop_s1_tid;
  logic [63:0] ooe_miu_memop_s2_tid;
  logic [63:0] ooe_miu_memop_s3_tid;
`endif
  // ccv_miu_ooe_cmpl: miu -> ooe, 1 copy x 4 slots
  logic miu_ooe_cmpl_s0_valid;
  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s0_payload;
  logic miu_ooe_cmpl_s0_credit;
  logic miu_ooe_cmpl_s0_stall;
  logic miu_ooe_cmpl_s1_valid;
  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s1_payload;
  logic miu_ooe_cmpl_s1_credit;
  logic miu_ooe_cmpl_s1_stall;
  logic miu_ooe_cmpl_s2_valid;
  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s2_payload;
  logic miu_ooe_cmpl_s2_credit;
  logic miu_ooe_cmpl_s2_stall;
  logic miu_ooe_cmpl_s3_valid;
  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s3_payload;
  logic miu_ooe_cmpl_s3_credit;
  logic miu_ooe_cmpl_s3_stall;
  logic miu_ooe_cmpl_wake;
`ifdef CCV_TRACE
  logic [63:0] miu_ooe_cmpl_s0_tid;
  logic [63:0] miu_ooe_cmpl_s1_tid;
  logic [63:0] miu_ooe_cmpl_s2_tid;
  logic [63:0] miu_ooe_cmpl_s3_tid;
`endif
  // ccv_ooe_miu_retire: ooe -> miu, 1 copy x 4 slots
  logic ooe_miu_retire_s0_valid;
  ccv_ooe_miu_retire_t ooe_miu_retire_s0_payload;
  logic ooe_miu_retire_s0_credit;
  logic ooe_miu_retire_s0_stall;
  logic ooe_miu_retire_s1_valid;
  ccv_ooe_miu_retire_t ooe_miu_retire_s1_payload;
  logic ooe_miu_retire_s1_credit;
  logic ooe_miu_retire_s1_stall;
  logic ooe_miu_retire_s2_valid;
  ccv_ooe_miu_retire_t ooe_miu_retire_s2_payload;
  logic ooe_miu_retire_s2_credit;
  logic ooe_miu_retire_s2_stall;
  logic ooe_miu_retire_s3_valid;
  ccv_ooe_miu_retire_t ooe_miu_retire_s3_payload;
  logic ooe_miu_retire_s3_credit;
  logic ooe_miu_retire_s3_stall;
  logic ooe_miu_retire_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_miu_retire_s0_tid;
  logic [63:0] ooe_miu_retire_s1_tid;
  logic [63:0] ooe_miu_retire_s2_tid;
  logic [63:0] ooe_miu_retire_s3_tid;
`endif
  // ccv_ooe_fet_redirect: ooe -> fet, 1 copy x 1 slot
  logic ooe_fet_redirect_valid;
  ccv_ooe_fet_redirect_t ooe_fet_redirect_payload;
  logic ooe_fet_redirect_credit;
  logic ooe_fet_redirect_stall;
  logic ooe_fet_redirect_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_fet_redirect_tid;
`endif
  // ccv_miu_spm_req: miu -> spm, 1 copy x 4 slots
  logic miu_spm_req_s0_valid;
  ccv_miu_spm_req_t miu_spm_req_s0_payload;
  logic miu_spm_req_s0_credit;
  logic miu_spm_req_s0_stall;
  logic miu_spm_req_s1_valid;
  ccv_miu_spm_req_t miu_spm_req_s1_payload;
  logic miu_spm_req_s1_credit;
  logic miu_spm_req_s1_stall;
  logic miu_spm_req_s2_valid;
  ccv_miu_spm_req_t miu_spm_req_s2_payload;
  logic miu_spm_req_s2_credit;
  logic miu_spm_req_s2_stall;
  logic miu_spm_req_s3_valid;
  ccv_miu_spm_req_t miu_spm_req_s3_payload;
  logic miu_spm_req_s3_credit;
  logic miu_spm_req_s3_stall;
  logic miu_spm_req_wake;
`ifdef CCV_TRACE
  logic [63:0] miu_spm_req_s0_tid;
  logic [63:0] miu_spm_req_s1_tid;
  logic [63:0] miu_spm_req_s2_tid;
  logic [63:0] miu_spm_req_s3_tid;
`endif
  // ccv_spm_miu_rsp: spm -> miu, 1 copy x 4 slots
  logic spm_miu_rsp_s0_valid;
  ccv_spm_miu_rsp_t spm_miu_rsp_s0_payload;
  logic spm_miu_rsp_s0_credit;
  logic spm_miu_rsp_s0_stall;
  logic spm_miu_rsp_s1_valid;
  ccv_spm_miu_rsp_t spm_miu_rsp_s1_payload;
  logic spm_miu_rsp_s1_credit;
  logic spm_miu_rsp_s1_stall;
  logic spm_miu_rsp_s2_valid;
  ccv_spm_miu_rsp_t spm_miu_rsp_s2_payload;
  logic spm_miu_rsp_s2_credit;
  logic spm_miu_rsp_s2_stall;
  logic spm_miu_rsp_s3_valid;
  ccv_spm_miu_rsp_t spm_miu_rsp_s3_payload;
  logic spm_miu_rsp_s3_credit;
  logic spm_miu_rsp_s3_stall;
  logic spm_miu_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] spm_miu_rsp_s0_tid;
  logic [63:0] spm_miu_rsp_s1_tid;
  logic [63:0] spm_miu_rsp_s2_tid;
  logic [63:0] spm_miu_rsp_s3_tid;
`endif
  // ccv_miu_dcu_req: miu -> dcu, 1 copy x 4 slots
  logic miu_dcu_req_s0_valid;
  ccv_miu_dcu_req_t miu_dcu_req_s0_payload;
  logic miu_dcu_req_s0_credit;
  logic miu_dcu_req_s0_stall;
  logic miu_dcu_req_s1_valid;
  ccv_miu_dcu_req_t miu_dcu_req_s1_payload;
  logic miu_dcu_req_s1_credit;
  logic miu_dcu_req_s1_stall;
  logic miu_dcu_req_s2_valid;
  ccv_miu_dcu_req_t miu_dcu_req_s2_payload;
  logic miu_dcu_req_s2_credit;
  logic miu_dcu_req_s2_stall;
  logic miu_dcu_req_s3_valid;
  ccv_miu_dcu_req_t miu_dcu_req_s3_payload;
  logic miu_dcu_req_s3_credit;
  logic miu_dcu_req_s3_stall;
  logic miu_dcu_req_wake;
`ifdef CCV_TRACE
  logic [63:0] miu_dcu_req_s0_tid;
  logic [63:0] miu_dcu_req_s1_tid;
  logic [63:0] miu_dcu_req_s2_tid;
  logic [63:0] miu_dcu_req_s3_tid;
`endif
  // ccv_dcu_miu_rsp: dcu -> miu, 1 copy x 4 slots
  logic dcu_miu_rsp_s0_valid;
  ccv_dcu_miu_rsp_t dcu_miu_rsp_s0_payload;
  logic dcu_miu_rsp_s0_credit;
  logic dcu_miu_rsp_s0_stall;
  logic dcu_miu_rsp_s1_valid;
  ccv_dcu_miu_rsp_t dcu_miu_rsp_s1_payload;
  logic dcu_miu_rsp_s1_credit;
  logic dcu_miu_rsp_s1_stall;
  logic dcu_miu_rsp_s2_valid;
  ccv_dcu_miu_rsp_t dcu_miu_rsp_s2_payload;
  logic dcu_miu_rsp_s2_credit;
  logic dcu_miu_rsp_s2_stall;
  logic dcu_miu_rsp_s3_valid;
  ccv_dcu_miu_rsp_t dcu_miu_rsp_s3_payload;
  logic dcu_miu_rsp_s3_credit;
  logic dcu_miu_rsp_s3_stall;
  logic dcu_miu_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] dcu_miu_rsp_s0_tid;
  logic [63:0] dcu_miu_rsp_s1_tid;
  logic [63:0] dcu_miu_rsp_s2_tid;
  logic [63:0] dcu_miu_rsp_s3_tid;
`endif
  // ccv_dcu_mlc_req: dcu -> mlc, 1 copy x 1 slot
  logic dcu_mlc_req_valid;
  ccv_dcu_mlc_req_t dcu_mlc_req_payload;
  logic dcu_mlc_req_credit;
  logic dcu_mlc_req_stall;
  logic dcu_mlc_req_wake;
`ifdef CCV_TRACE
  logic [63:0] dcu_mlc_req_tid;
`endif
  // ccv_mlc_dcu_rsp: mlc -> dcu, 1 copy x 1 slot
  logic mlc_dcu_rsp_valid;
  ccv_mlc_dcu_rsp_t mlc_dcu_rsp_payload;
  logic mlc_dcu_rsp_credit;
  logic mlc_dcu_rsp_stall;
  logic mlc_dcu_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_dcu_rsp_tid;
`endif
  // ccv_mlc_dcu_probe: mlc -> dcu, 1 copy x 1 slot
  logic mlc_dcu_probe_valid;
  ccv_mlc_dcu_probe_t mlc_dcu_probe_payload;
  logic mlc_dcu_probe_credit;
  logic mlc_dcu_probe_stall;
  logic mlc_dcu_probe_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_dcu_probe_tid;
`endif
  // ccv_dcu_mlc_probe_ack: dcu -> mlc, 1 copy x 1 slot
  logic dcu_mlc_probe_ack_valid;
  ccv_dcu_mlc_probe_ack_t dcu_mlc_probe_ack_payload;
  logic dcu_mlc_probe_ack_credit;
  logic dcu_mlc_probe_ack_stall;
  logic dcu_mlc_probe_ack_wake;
`ifdef CCV_TRACE
  logic [63:0] dcu_mlc_probe_ack_tid;
`endif
  // ccv_fet_mlc_ifill: fet -> mlc, 1 copy x 1 slot
  logic fet_mlc_ifill_valid;
  ccv_fet_mlc_ifill_t fet_mlc_ifill_payload;
  logic fet_mlc_ifill_credit;
  logic fet_mlc_ifill_stall;
  logic fet_mlc_ifill_wake;
`ifdef CCV_TRACE
  logic [63:0] fet_mlc_ifill_tid;
`endif
  // ccv_mlc_fet_ifill_rsp: mlc -> fet, 1 copy x 1 slot
  logic mlc_fet_ifill_rsp_valid;
  ccv_mlc_fet_ifill_rsp_t mlc_fet_ifill_rsp_payload;
  logic mlc_fet_ifill_rsp_credit;
  logic mlc_fet_ifill_rsp_stall;
  logic mlc_fet_ifill_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_fet_ifill_rsp_tid;
`endif
  // ccv_miu_fet_itlb: miu -> fet, 1 copy x 1 slot
  logic miu_fet_itlb_valid;
  ccv_miu_fet_itlb_t miu_fet_itlb_payload;
  logic miu_fet_itlb_credit;
  logic miu_fet_itlb_stall;
  logic miu_fet_itlb_wake;
`ifdef CCV_TRACE
  logic [63:0] miu_fet_itlb_tid;
`endif
  // ccv_fet_miu_itlb_req: fet -> miu, 1 copy x 1 slot
  logic fet_miu_itlb_req_valid;
  ccv_fet_miu_itlb_req_t fet_miu_itlb_req_payload;
  logic fet_miu_itlb_req_credit;
  logic fet_miu_itlb_req_stall;
  logic fet_miu_itlb_req_wake;
`ifdef CCV_TRACE
  logic [63:0] fet_miu_itlb_req_tid;
`endif
  // ccv_mlc_exb_req: mlc -> exb, 1 copy x 1 slot
  logic mlc_exb_req_valid;
  ccv_mlc_exb_req_t mlc_exb_req_payload;
  logic mlc_exb_req_credit;
  logic mlc_exb_req_stall;
  logic mlc_exb_req_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_exb_req_tid;
`endif
  // ccv_exb_mlc_rsp: exb -> mlc, 1 copy x 1 slot
  logic exb_mlc_rsp_valid;
  ccv_exb_mlc_rsp_t exb_mlc_rsp_payload;
  logic exb_mlc_rsp_credit;
  logic exb_mlc_rsp_stall;
  logic exb_mlc_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] exb_mlc_rsp_tid;
`endif
  // ccv_rau_fet_launch: rau -> fet, 1 copy x 1 slot
  logic rau_fet_launch_valid;
  ccv_rau_fet_launch_t rau_fet_launch_payload;
  logic rau_fet_launch_credit;
  logic rau_fet_launch_stall;
  logic rau_fet_launch_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_fet_launch_tid;
`endif
  // ccv_rau_ooe_alloc: rau -> ooe, 1 copy x 1 slot
  logic rau_ooe_alloc_valid;
  ccv_rau_ooe_alloc_t rau_ooe_alloc_payload;
  logic rau_ooe_alloc_credit;
  logic rau_ooe_alloc_stall;
  logic rau_ooe_alloc_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_ooe_alloc_tid;
`endif
  // ccv_ooe_rau_status: ooe -> rau, 1 copy x 1 slot
  logic ooe_rau_status_valid;
  ccv_ooe_rau_status_t ooe_rau_status_payload;
  logic ooe_rau_status_credit;
  logic ooe_rau_status_stall;
  logic ooe_rau_status_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_rau_status_tid;
`endif
  // ccv_rau_ooe_demote: rau -> ooe, 1 copy x 1 slot
  logic rau_ooe_demote_valid;
  ccv_rau_ooe_demote_t rau_ooe_demote_payload;
  logic rau_ooe_demote_credit;
  logic rau_ooe_demote_stall;
  logic rau_ooe_demote_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_ooe_demote_tid;
`endif
  // ccv_ooe_rau_drained: ooe -> rau, 1 copy x 1 slot
  logic ooe_rau_drained_valid;
  ccv_ooe_rau_drained_t ooe_rau_drained_payload;
  logic ooe_rau_drained_credit;
  logic ooe_rau_drained_stall;
  logic ooe_rau_drained_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_rau_drained_tid;
`endif
  // ccv_rau_rcu_mig: rau -> rcu, 1 copy x 1 slot
  logic rau_rcu_mig_valid;
  ccv_rau_rcu_mig_t rau_rcu_mig_payload;
  logic rau_rcu_mig_credit;
  logic rau_rcu_mig_stall;
  logic rau_rcu_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_rcu_mig_tid;
`endif
  // ccv_rcu_pca_mig: rcu -> pca, 1 copy x 1 slot
  logic rcu_pca_mig_valid;
  ccv_rcu_pca_mig_t rcu_pca_mig_payload;
  logic rcu_pca_mig_credit;
  logic rcu_pca_mig_stall;
  logic rcu_pca_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] rcu_pca_mig_tid;
`endif
  // ccv_pca_rcu_mig: pca -> rcu, 1 copy x 1 slot
  logic pca_rcu_mig_valid;
  ccv_pca_rcu_mig_t pca_rcu_mig_payload;
  logic pca_rcu_mig_credit;
  logic pca_rcu_mig_stall;
  logic pca_rcu_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] pca_rcu_mig_tid;
`endif
  // ccv_fet_pca_mig: fet -> pca, 1 copy x 1 slot
  logic fet_pca_mig_valid;
  ccv_fet_pca_mig_t fet_pca_mig_payload;
  logic fet_pca_mig_credit;
  logic fet_pca_mig_stall;
  logic fet_pca_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] fet_pca_mig_tid;
`endif
  // ccv_pca_fet_mig: pca -> fet, 1 copy x 1 slot
  logic pca_fet_mig_valid;
  ccv_pca_fet_mig_t pca_fet_mig_payload;
  logic pca_fet_mig_credit;
  logic pca_fet_mig_stall;
  logic pca_fet_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] pca_fet_mig_tid;
`endif
  // ccv_rau_fet_mig: rau -> fet, 1 copy x 1 slot
  logic rau_fet_mig_valid;
  ccv_rau_fet_mig_t rau_fet_mig_payload;
  logic rau_fet_mig_credit;
  logic rau_fet_mig_stall;
  logic rau_fet_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_fet_mig_tid;
`endif
  // ccv_pca_rau_mig_done: pca -> rau, 1 copy x 1 slot
  logic pca_rau_mig_done_valid;
  ccv_pca_rau_mig_done_t pca_rau_mig_done_payload;
  logic pca_rau_mig_done_credit;
  logic pca_rau_mig_done_stall;
  logic pca_rau_mig_done_wake;
`ifdef CCV_TRACE
  logic [63:0] pca_rau_mig_done_tid;
`endif
  // ccv_rau_miu_cta: rau -> miu, 1 copy x 1 slot
  logic rau_miu_cta_valid;
  ccv_rau_miu_cta_t rau_miu_cta_payload;
  logic rau_miu_cta_credit;
  logic rau_miu_cta_stall;
  logic rau_miu_cta_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_miu_cta_tid;
`endif
  // ccv_ooe_syu_bar: ooe -> syu, 1 copy x 1 slot
  logic ooe_syu_bar_valid;
  ccv_ooe_syu_bar_t ooe_syu_bar_payload;
  logic ooe_syu_bar_credit;
  logic ooe_syu_bar_stall;
  logic ooe_syu_bar_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_syu_bar_tid;
`endif
  // ccv_syu_ooe_rel: syu -> ooe, 1 copy x 1 slot
  logic syu_ooe_rel_valid;
  ccv_syu_ooe_rel_t syu_ooe_rel_payload;
  logic syu_ooe_rel_credit;
  logic syu_ooe_rel_stall;
  logic syu_ooe_rel_wake;
`ifdef CCV_TRACE
  logic [63:0] syu_ooe_rel_tid;
`endif
  // ccv_rau_syu_alloc: rau -> syu, 1 copy x 1 slot
  logic rau_syu_alloc_valid;
  ccv_rau_syu_alloc_t rau_syu_alloc_payload;
  logic rau_syu_alloc_credit;
  logic rau_syu_alloc_stall;
  logic rau_syu_alloc_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_syu_alloc_tid;
`endif
  // ccv_ooe_cru_fault: ooe -> cru, 1 copy x 1 slot
  logic ooe_cru_fault_valid;
  ccv_ooe_cru_fault_t ooe_cru_fault_payload;
  logic ooe_cru_fault_credit;
  logic ooe_cru_fault_stall;
  logic ooe_cru_fault_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_cru_fault_tid;
`endif
  // ccv_cru_rau_cfg: cru -> rau, 1 copy x 1 slot
  logic cru_rau_cfg_valid;
  ccv_cru_rau_cfg_t cru_rau_cfg_payload;
  logic cru_rau_cfg_credit;
  logic cru_rau_cfg_stall;
  logic cru_rau_cfg_wake;
`ifdef CCV_TRACE
  logic [63:0] cru_rau_cfg_tid;
`endif

  // Per-block gated clocks: each block's sleep_ok drives its own
  // gate and nothing else. A stub holds sleep_ok low, so its clock
  // runs; a real block's wake detector (on clk_free) lowers it when
  // a _wake arrives on one of its input channels.
  logic fet_sleep_ok;
  wire fet_core_clk = core_clk & ~fet_sleep_ok;
  logic dec_sleep_ok;
  wire dec_core_clk = core_clk & ~dec_sleep_ok;
  logic ooe_sleep_ok;
  wire ooe_core_clk = core_clk & ~ooe_sleep_ok;
  logic rcu_sleep_ok;
  wire rcu_core_clk = core_clk & ~rcu_sleep_ok;
  logic lane_00_sleep_ok;
  wire lane_00_core_clk = core_clk & ~lane_00_sleep_ok;
  logic lane_01_sleep_ok;
  wire lane_01_core_clk = core_clk & ~lane_01_sleep_ok;
  logic lane_02_sleep_ok;
  wire lane_02_core_clk = core_clk & ~lane_02_sleep_ok;
  logic lane_03_sleep_ok;
  wire lane_03_core_clk = core_clk & ~lane_03_sleep_ok;
  logic lane_04_sleep_ok;
  wire lane_04_core_clk = core_clk & ~lane_04_sleep_ok;
  logic lane_05_sleep_ok;
  wire lane_05_core_clk = core_clk & ~lane_05_sleep_ok;
  logic lane_06_sleep_ok;
  wire lane_06_core_clk = core_clk & ~lane_06_sleep_ok;
  logic lane_07_sleep_ok;
  wire lane_07_core_clk = core_clk & ~lane_07_sleep_ok;
  logic lane_08_sleep_ok;
  wire lane_08_core_clk = core_clk & ~lane_08_sleep_ok;
  logic lane_09_sleep_ok;
  wire lane_09_core_clk = core_clk & ~lane_09_sleep_ok;
  logic lane_10_sleep_ok;
  wire lane_10_core_clk = core_clk & ~lane_10_sleep_ok;
  logic lane_11_sleep_ok;
  wire lane_11_core_clk = core_clk & ~lane_11_sleep_ok;
  logic lane_12_sleep_ok;
  wire lane_12_core_clk = core_clk & ~lane_12_sleep_ok;
  logic lane_13_sleep_ok;
  wire lane_13_core_clk = core_clk & ~lane_13_sleep_ok;
  logic lane_14_sleep_ok;
  wire lane_14_core_clk = core_clk & ~lane_14_sleep_ok;
  logic lane_15_sleep_ok;
  wire lane_15_core_clk = core_clk & ~lane_15_sleep_ok;
  logic lane_16_sleep_ok;
  wire lane_16_core_clk = core_clk & ~lane_16_sleep_ok;
  logic lane_17_sleep_ok;
  wire lane_17_core_clk = core_clk & ~lane_17_sleep_ok;
  logic lane_18_sleep_ok;
  wire lane_18_core_clk = core_clk & ~lane_18_sleep_ok;
  logic lane_19_sleep_ok;
  wire lane_19_core_clk = core_clk & ~lane_19_sleep_ok;
  logic lane_20_sleep_ok;
  wire lane_20_core_clk = core_clk & ~lane_20_sleep_ok;
  logic lane_21_sleep_ok;
  wire lane_21_core_clk = core_clk & ~lane_21_sleep_ok;
  logic lane_22_sleep_ok;
  wire lane_22_core_clk = core_clk & ~lane_22_sleep_ok;
  logic lane_23_sleep_ok;
  wire lane_23_core_clk = core_clk & ~lane_23_sleep_ok;
  logic lane_24_sleep_ok;
  wire lane_24_core_clk = core_clk & ~lane_24_sleep_ok;
  logic lane_25_sleep_ok;
  wire lane_25_core_clk = core_clk & ~lane_25_sleep_ok;
  logic lane_26_sleep_ok;
  wire lane_26_core_clk = core_clk & ~lane_26_sleep_ok;
  logic lane_27_sleep_ok;
  wire lane_27_core_clk = core_clk & ~lane_27_sleep_ok;
  logic lane_28_sleep_ok;
  wire lane_28_core_clk = core_clk & ~lane_28_sleep_ok;
  logic lane_29_sleep_ok;
  wire lane_29_core_clk = core_clk & ~lane_29_sleep_ok;
  logic lane_30_sleep_ok;
  wire lane_30_core_clk = core_clk & ~lane_30_sleep_ok;
  logic lane_31_sleep_ok;
  wire lane_31_core_clk = core_clk & ~lane_31_sleep_ok;
  logic miu_sleep_ok;
  wire miu_core_clk = core_clk & ~miu_sleep_ok;
  logic spm_sleep_ok;
  wire spm_core_clk = core_clk & ~spm_sleep_ok;
  logic dcu_sleep_ok;
  wire dcu_core_clk = core_clk & ~dcu_sleep_ok;
  logic mlc_sleep_ok;
  wire mlc_core_clk = core_clk & ~mlc_sleep_ok;
  logic rau_sleep_ok;
  wire rau_core_clk = core_clk & ~rau_sleep_ok;
  logic syu_sleep_ok;
  wire syu_core_clk = core_clk & ~syu_sleep_ok;
  logic pca_sleep_ok;
  wire pca_core_clk = core_clk & ~pca_sleep_ok;
  logic cru_sleep_ok;
  wire cru_core_clk = core_clk & ~cru_sleep_ok;
  logic exb_sleep_ok;
  wire exb_core_clk = core_clk & ~exb_sleep_ok;

  ccv_fet u_fet (
    .clk(fet_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[0]),
    .kill_ack_epoch(kill_ack_epoch[0 +: 2]),
    .sleep_ok(fet_sleep_ok),
    .csr_req(csr_reqs[0 +: 49]),
    .csr_rsp(csr_rsps[0 +: 33]),
    .csr_credit(csr_credits[0]),
    .fet_dec_instr_s0_valid(fet_dec_instr_s0_valid),
    .fet_dec_instr_s0_payload(fet_dec_instr_s0_payload),
    .fet_dec_instr_s0_credit(fet_dec_instr_s0_credit),
    .fet_dec_instr_s0_stall(fet_dec_instr_s0_stall),
    .fet_dec_instr_s1_valid(fet_dec_instr_s1_valid),
    .fet_dec_instr_s1_payload(fet_dec_instr_s1_payload),
    .fet_dec_instr_s1_credit(fet_dec_instr_s1_credit),
    .fet_dec_instr_s1_stall(fet_dec_instr_s1_stall),
    .fet_dec_instr_s2_valid(fet_dec_instr_s2_valid),
    .fet_dec_instr_s2_payload(fet_dec_instr_s2_payload),
    .fet_dec_instr_s2_credit(fet_dec_instr_s2_credit),
    .fet_dec_instr_s2_stall(fet_dec_instr_s2_stall),
    .fet_dec_instr_s3_valid(fet_dec_instr_s3_valid),
    .fet_dec_instr_s3_payload(fet_dec_instr_s3_payload),
    .fet_dec_instr_s3_credit(fet_dec_instr_s3_credit),
    .fet_dec_instr_s3_stall(fet_dec_instr_s3_stall),
    .fet_dec_instr_s4_valid(fet_dec_instr_s4_valid),
    .fet_dec_instr_s4_payload(fet_dec_instr_s4_payload),
    .fet_dec_instr_s4_credit(fet_dec_instr_s4_credit),
    .fet_dec_instr_s4_stall(fet_dec_instr_s4_stall),
    .fet_dec_instr_s5_valid(fet_dec_instr_s5_valid),
    .fet_dec_instr_s5_payload(fet_dec_instr_s5_payload),
    .fet_dec_instr_s5_credit(fet_dec_instr_s5_credit),
    .fet_dec_instr_s5_stall(fet_dec_instr_s5_stall),
    .fet_dec_instr_s6_valid(fet_dec_instr_s6_valid),
    .fet_dec_instr_s6_payload(fet_dec_instr_s6_payload),
    .fet_dec_instr_s6_credit(fet_dec_instr_s6_credit),
    .fet_dec_instr_s6_stall(fet_dec_instr_s6_stall),
    .fet_dec_instr_s7_valid(fet_dec_instr_s7_valid),
    .fet_dec_instr_s7_payload(fet_dec_instr_s7_payload),
    .fet_dec_instr_s7_credit(fet_dec_instr_s7_credit),
    .fet_dec_instr_s7_stall(fet_dec_instr_s7_stall),
    .fet_dec_instr_wake(fet_dec_instr_wake),
    .ooe_fet_redirect_valid(ooe_fet_redirect_valid),
    .ooe_fet_redirect_payload(ooe_fet_redirect_payload),
    .ooe_fet_redirect_credit(ooe_fet_redirect_credit),
    .ooe_fet_redirect_stall(ooe_fet_redirect_stall),
    .ooe_fet_redirect_wake(ooe_fet_redirect_wake),
    .fet_mlc_ifill_valid(fet_mlc_ifill_valid),
    .fet_mlc_ifill_payload(fet_mlc_ifill_payload),
    .fet_mlc_ifill_credit(fet_mlc_ifill_credit),
    .fet_mlc_ifill_stall(fet_mlc_ifill_stall),
    .fet_mlc_ifill_wake(fet_mlc_ifill_wake),
    .mlc_fet_ifill_rsp_valid(mlc_fet_ifill_rsp_valid),
    .mlc_fet_ifill_rsp_payload(mlc_fet_ifill_rsp_payload),
    .mlc_fet_ifill_rsp_credit(mlc_fet_ifill_rsp_credit),
    .mlc_fet_ifill_rsp_stall(mlc_fet_ifill_rsp_stall),
    .mlc_fet_ifill_rsp_wake(mlc_fet_ifill_rsp_wake),
    .miu_fet_itlb_valid(miu_fet_itlb_valid),
    .miu_fet_itlb_payload(miu_fet_itlb_payload),
    .miu_fet_itlb_credit(miu_fet_itlb_credit),
    .miu_fet_itlb_stall(miu_fet_itlb_stall),
    .miu_fet_itlb_wake(miu_fet_itlb_wake),
    .fet_miu_itlb_req_valid(fet_miu_itlb_req_valid),
    .fet_miu_itlb_req_payload(fet_miu_itlb_req_payload),
    .fet_miu_itlb_req_credit(fet_miu_itlb_req_credit),
    .fet_miu_itlb_req_stall(fet_miu_itlb_req_stall),
    .fet_miu_itlb_req_wake(fet_miu_itlb_req_wake),
    .rau_fet_launch_valid(rau_fet_launch_valid),
    .rau_fet_launch_payload(rau_fet_launch_payload),
    .rau_fet_launch_credit(rau_fet_launch_credit),
    .rau_fet_launch_stall(rau_fet_launch_stall),
    .rau_fet_launch_wake(rau_fet_launch_wake),
    .fet_pca_mig_valid(fet_pca_mig_valid),
    .fet_pca_mig_payload(fet_pca_mig_payload),
    .fet_pca_mig_credit(fet_pca_mig_credit),
    .fet_pca_mig_stall(fet_pca_mig_stall),
    .fet_pca_mig_wake(fet_pca_mig_wake),
    .pca_fet_mig_valid(pca_fet_mig_valid),
    .pca_fet_mig_payload(pca_fet_mig_payload),
    .pca_fet_mig_credit(pca_fet_mig_credit),
    .pca_fet_mig_stall(pca_fet_mig_stall),
    .pca_fet_mig_wake(pca_fet_mig_wake),
    .rau_fet_mig_valid(rau_fet_mig_valid),
    .rau_fet_mig_payload(rau_fet_mig_payload),
    .rau_fet_mig_credit(rau_fet_mig_credit),
    .rau_fet_mig_stall(rau_fet_mig_stall),
    .rau_fet_mig_wake(rau_fet_mig_wake)
`ifdef CCV_TRACE
    , .fet_dec_instr_s0_tid(fet_dec_instr_s0_tid),
      .fet_dec_instr_s1_tid(fet_dec_instr_s1_tid),
      .fet_dec_instr_s2_tid(fet_dec_instr_s2_tid),
      .fet_dec_instr_s3_tid(fet_dec_instr_s3_tid),
      .fet_dec_instr_s4_tid(fet_dec_instr_s4_tid),
      .fet_dec_instr_s5_tid(fet_dec_instr_s5_tid),
      .fet_dec_instr_s6_tid(fet_dec_instr_s6_tid),
      .fet_dec_instr_s7_tid(fet_dec_instr_s7_tid),
      .ooe_fet_redirect_tid(ooe_fet_redirect_tid),
      .fet_mlc_ifill_tid(fet_mlc_ifill_tid),
      .mlc_fet_ifill_rsp_tid(mlc_fet_ifill_rsp_tid),
      .miu_fet_itlb_tid(miu_fet_itlb_tid),
      .fet_miu_itlb_req_tid(fet_miu_itlb_req_tid),
      .rau_fet_launch_tid(rau_fet_launch_tid),
      .fet_pca_mig_tid(fet_pca_mig_tid),
      .pca_fet_mig_tid(pca_fet_mig_tid),
      .rau_fet_mig_tid(rau_fet_mig_tid)
`endif
  );

  ccv_dec u_dec (
    .clk(dec_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[1]),
    .kill_ack_epoch(kill_ack_epoch[2 +: 2]),
    .sleep_ok(dec_sleep_ok),
    .csr_req(csr_reqs[49 +: 49]),
    .csr_rsp(csr_rsps[33 +: 33]),
    .csr_credit(csr_credits[1]),
    .fet_dec_instr_s0_valid(fet_dec_instr_s0_valid),
    .fet_dec_instr_s0_payload(fet_dec_instr_s0_payload),
    .fet_dec_instr_s0_credit(fet_dec_instr_s0_credit),
    .fet_dec_instr_s0_stall(fet_dec_instr_s0_stall),
    .fet_dec_instr_s1_valid(fet_dec_instr_s1_valid),
    .fet_dec_instr_s1_payload(fet_dec_instr_s1_payload),
    .fet_dec_instr_s1_credit(fet_dec_instr_s1_credit),
    .fet_dec_instr_s1_stall(fet_dec_instr_s1_stall),
    .fet_dec_instr_s2_valid(fet_dec_instr_s2_valid),
    .fet_dec_instr_s2_payload(fet_dec_instr_s2_payload),
    .fet_dec_instr_s2_credit(fet_dec_instr_s2_credit),
    .fet_dec_instr_s2_stall(fet_dec_instr_s2_stall),
    .fet_dec_instr_s3_valid(fet_dec_instr_s3_valid),
    .fet_dec_instr_s3_payload(fet_dec_instr_s3_payload),
    .fet_dec_instr_s3_credit(fet_dec_instr_s3_credit),
    .fet_dec_instr_s3_stall(fet_dec_instr_s3_stall),
    .fet_dec_instr_s4_valid(fet_dec_instr_s4_valid),
    .fet_dec_instr_s4_payload(fet_dec_instr_s4_payload),
    .fet_dec_instr_s4_credit(fet_dec_instr_s4_credit),
    .fet_dec_instr_s4_stall(fet_dec_instr_s4_stall),
    .fet_dec_instr_s5_valid(fet_dec_instr_s5_valid),
    .fet_dec_instr_s5_payload(fet_dec_instr_s5_payload),
    .fet_dec_instr_s5_credit(fet_dec_instr_s5_credit),
    .fet_dec_instr_s5_stall(fet_dec_instr_s5_stall),
    .fet_dec_instr_s6_valid(fet_dec_instr_s6_valid),
    .fet_dec_instr_s6_payload(fet_dec_instr_s6_payload),
    .fet_dec_instr_s6_credit(fet_dec_instr_s6_credit),
    .fet_dec_instr_s6_stall(fet_dec_instr_s6_stall),
    .fet_dec_instr_s7_valid(fet_dec_instr_s7_valid),
    .fet_dec_instr_s7_payload(fet_dec_instr_s7_payload),
    .fet_dec_instr_s7_credit(fet_dec_instr_s7_credit),
    .fet_dec_instr_s7_stall(fet_dec_instr_s7_stall),
    .fet_dec_instr_wake(fet_dec_instr_wake),
    .dec_ooe_uop_s0_valid(dec_ooe_uop_s0_valid),
    .dec_ooe_uop_s0_payload(dec_ooe_uop_s0_payload),
    .dec_ooe_uop_s0_credit(dec_ooe_uop_s0_credit),
    .dec_ooe_uop_s0_stall(dec_ooe_uop_s0_stall),
    .dec_ooe_uop_s1_valid(dec_ooe_uop_s1_valid),
    .dec_ooe_uop_s1_payload(dec_ooe_uop_s1_payload),
    .dec_ooe_uop_s1_credit(dec_ooe_uop_s1_credit),
    .dec_ooe_uop_s1_stall(dec_ooe_uop_s1_stall),
    .dec_ooe_uop_s2_valid(dec_ooe_uop_s2_valid),
    .dec_ooe_uop_s2_payload(dec_ooe_uop_s2_payload),
    .dec_ooe_uop_s2_credit(dec_ooe_uop_s2_credit),
    .dec_ooe_uop_s2_stall(dec_ooe_uop_s2_stall),
    .dec_ooe_uop_s3_valid(dec_ooe_uop_s3_valid),
    .dec_ooe_uop_s3_payload(dec_ooe_uop_s3_payload),
    .dec_ooe_uop_s3_credit(dec_ooe_uop_s3_credit),
    .dec_ooe_uop_s3_stall(dec_ooe_uop_s3_stall),
    .dec_ooe_uop_s4_valid(dec_ooe_uop_s4_valid),
    .dec_ooe_uop_s4_payload(dec_ooe_uop_s4_payload),
    .dec_ooe_uop_s4_credit(dec_ooe_uop_s4_credit),
    .dec_ooe_uop_s4_stall(dec_ooe_uop_s4_stall),
    .dec_ooe_uop_s5_valid(dec_ooe_uop_s5_valid),
    .dec_ooe_uop_s5_payload(dec_ooe_uop_s5_payload),
    .dec_ooe_uop_s5_credit(dec_ooe_uop_s5_credit),
    .dec_ooe_uop_s5_stall(dec_ooe_uop_s5_stall),
    .dec_ooe_uop_wake(dec_ooe_uop_wake)
`ifdef CCV_TRACE
    , .fet_dec_instr_s0_tid(fet_dec_instr_s0_tid),
      .fet_dec_instr_s1_tid(fet_dec_instr_s1_tid),
      .fet_dec_instr_s2_tid(fet_dec_instr_s2_tid),
      .fet_dec_instr_s3_tid(fet_dec_instr_s3_tid),
      .fet_dec_instr_s4_tid(fet_dec_instr_s4_tid),
      .fet_dec_instr_s5_tid(fet_dec_instr_s5_tid),
      .fet_dec_instr_s6_tid(fet_dec_instr_s6_tid),
      .fet_dec_instr_s7_tid(fet_dec_instr_s7_tid),
      .dec_ooe_uop_s0_tid(dec_ooe_uop_s0_tid),
      .dec_ooe_uop_s1_tid(dec_ooe_uop_s1_tid),
      .dec_ooe_uop_s2_tid(dec_ooe_uop_s2_tid),
      .dec_ooe_uop_s3_tid(dec_ooe_uop_s3_tid),
      .dec_ooe_uop_s4_tid(dec_ooe_uop_s4_tid),
      .dec_ooe_uop_s5_tid(dec_ooe_uop_s5_tid)
`endif
  );

  ccv_ooe u_ooe (
    .clk(ooe_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[2]),
    .kill_ack_epoch(kill_ack_epoch[4 +: 2]),
    .sleep_ok(ooe_sleep_ok),
    .csr_req(csr_reqs[98 +: 49]),
    .csr_rsp(csr_rsps[66 +: 33]),
    .csr_credit(csr_credits[2]),
    .dec_ooe_uop_s0_valid(dec_ooe_uop_s0_valid),
    .dec_ooe_uop_s0_payload(dec_ooe_uop_s0_payload),
    .dec_ooe_uop_s0_credit(dec_ooe_uop_s0_credit),
    .dec_ooe_uop_s0_stall(dec_ooe_uop_s0_stall),
    .dec_ooe_uop_s1_valid(dec_ooe_uop_s1_valid),
    .dec_ooe_uop_s1_payload(dec_ooe_uop_s1_payload),
    .dec_ooe_uop_s1_credit(dec_ooe_uop_s1_credit),
    .dec_ooe_uop_s1_stall(dec_ooe_uop_s1_stall),
    .dec_ooe_uop_s2_valid(dec_ooe_uop_s2_valid),
    .dec_ooe_uop_s2_payload(dec_ooe_uop_s2_payload),
    .dec_ooe_uop_s2_credit(dec_ooe_uop_s2_credit),
    .dec_ooe_uop_s2_stall(dec_ooe_uop_s2_stall),
    .dec_ooe_uop_s3_valid(dec_ooe_uop_s3_valid),
    .dec_ooe_uop_s3_payload(dec_ooe_uop_s3_payload),
    .dec_ooe_uop_s3_credit(dec_ooe_uop_s3_credit),
    .dec_ooe_uop_s3_stall(dec_ooe_uop_s3_stall),
    .dec_ooe_uop_s4_valid(dec_ooe_uop_s4_valid),
    .dec_ooe_uop_s4_payload(dec_ooe_uop_s4_payload),
    .dec_ooe_uop_s4_credit(dec_ooe_uop_s4_credit),
    .dec_ooe_uop_s4_stall(dec_ooe_uop_s4_stall),
    .dec_ooe_uop_s5_valid(dec_ooe_uop_s5_valid),
    .dec_ooe_uop_s5_payload(dec_ooe_uop_s5_payload),
    .dec_ooe_uop_s5_credit(dec_ooe_uop_s5_credit),
    .dec_ooe_uop_s5_stall(dec_ooe_uop_s5_stall),
    .dec_ooe_uop_wake(dec_ooe_uop_wake),
    .ooe_rcu_issue_s0_valid(ooe_rcu_issue_s0_valid),
    .ooe_rcu_issue_s0_payload(ooe_rcu_issue_s0_payload),
    .ooe_rcu_issue_s0_credit(ooe_rcu_issue_s0_credit),
    .ooe_rcu_issue_s0_stall(ooe_rcu_issue_s0_stall),
    .ooe_rcu_issue_s1_valid(ooe_rcu_issue_s1_valid),
    .ooe_rcu_issue_s1_payload(ooe_rcu_issue_s1_payload),
    .ooe_rcu_issue_s1_credit(ooe_rcu_issue_s1_credit),
    .ooe_rcu_issue_s1_stall(ooe_rcu_issue_s1_stall),
    .ooe_rcu_issue_s2_valid(ooe_rcu_issue_s2_valid),
    .ooe_rcu_issue_s2_payload(ooe_rcu_issue_s2_payload),
    .ooe_rcu_issue_s2_credit(ooe_rcu_issue_s2_credit),
    .ooe_rcu_issue_s2_stall(ooe_rcu_issue_s2_stall),
    .ooe_rcu_issue_s3_valid(ooe_rcu_issue_s3_valid),
    .ooe_rcu_issue_s3_payload(ooe_rcu_issue_s3_payload),
    .ooe_rcu_issue_s3_credit(ooe_rcu_issue_s3_credit),
    .ooe_rcu_issue_s3_stall(ooe_rcu_issue_s3_stall),
    .ooe_rcu_issue_wake(ooe_rcu_issue_wake),
    .rcu_ooe_done_s0_valid(rcu_ooe_done_s0_valid),
    .rcu_ooe_done_s0_payload(rcu_ooe_done_s0_payload),
    .rcu_ooe_done_s0_credit(rcu_ooe_done_s0_credit),
    .rcu_ooe_done_s0_stall(rcu_ooe_done_s0_stall),
    .rcu_ooe_done_s1_valid(rcu_ooe_done_s1_valid),
    .rcu_ooe_done_s1_payload(rcu_ooe_done_s1_payload),
    .rcu_ooe_done_s1_credit(rcu_ooe_done_s1_credit),
    .rcu_ooe_done_s1_stall(rcu_ooe_done_s1_stall),
    .rcu_ooe_done_s2_valid(rcu_ooe_done_s2_valid),
    .rcu_ooe_done_s2_payload(rcu_ooe_done_s2_payload),
    .rcu_ooe_done_s2_credit(rcu_ooe_done_s2_credit),
    .rcu_ooe_done_s2_stall(rcu_ooe_done_s2_stall),
    .rcu_ooe_done_s3_valid(rcu_ooe_done_s3_valid),
    .rcu_ooe_done_s3_payload(rcu_ooe_done_s3_payload),
    .rcu_ooe_done_s3_credit(rcu_ooe_done_s3_credit),
    .rcu_ooe_done_s3_stall(rcu_ooe_done_s3_stall),
    .rcu_ooe_done_wake(rcu_ooe_done_wake),
    .ooe_miu_memop_s0_valid(ooe_miu_memop_s0_valid),
    .ooe_miu_memop_s0_payload(ooe_miu_memop_s0_payload),
    .ooe_miu_memop_s0_credit(ooe_miu_memop_s0_credit),
    .ooe_miu_memop_s0_stall(ooe_miu_memop_s0_stall),
    .ooe_miu_memop_s1_valid(ooe_miu_memop_s1_valid),
    .ooe_miu_memop_s1_payload(ooe_miu_memop_s1_payload),
    .ooe_miu_memop_s1_credit(ooe_miu_memop_s1_credit),
    .ooe_miu_memop_s1_stall(ooe_miu_memop_s1_stall),
    .ooe_miu_memop_s2_valid(ooe_miu_memop_s2_valid),
    .ooe_miu_memop_s2_payload(ooe_miu_memop_s2_payload),
    .ooe_miu_memop_s2_credit(ooe_miu_memop_s2_credit),
    .ooe_miu_memop_s2_stall(ooe_miu_memop_s2_stall),
    .ooe_miu_memop_s3_valid(ooe_miu_memop_s3_valid),
    .ooe_miu_memop_s3_payload(ooe_miu_memop_s3_payload),
    .ooe_miu_memop_s3_credit(ooe_miu_memop_s3_credit),
    .ooe_miu_memop_s3_stall(ooe_miu_memop_s3_stall),
    .ooe_miu_memop_wake(ooe_miu_memop_wake),
    .miu_ooe_cmpl_s0_valid(miu_ooe_cmpl_s0_valid),
    .miu_ooe_cmpl_s0_payload(miu_ooe_cmpl_s0_payload),
    .miu_ooe_cmpl_s0_credit(miu_ooe_cmpl_s0_credit),
    .miu_ooe_cmpl_s0_stall(miu_ooe_cmpl_s0_stall),
    .miu_ooe_cmpl_s1_valid(miu_ooe_cmpl_s1_valid),
    .miu_ooe_cmpl_s1_payload(miu_ooe_cmpl_s1_payload),
    .miu_ooe_cmpl_s1_credit(miu_ooe_cmpl_s1_credit),
    .miu_ooe_cmpl_s1_stall(miu_ooe_cmpl_s1_stall),
    .miu_ooe_cmpl_s2_valid(miu_ooe_cmpl_s2_valid),
    .miu_ooe_cmpl_s2_payload(miu_ooe_cmpl_s2_payload),
    .miu_ooe_cmpl_s2_credit(miu_ooe_cmpl_s2_credit),
    .miu_ooe_cmpl_s2_stall(miu_ooe_cmpl_s2_stall),
    .miu_ooe_cmpl_s3_valid(miu_ooe_cmpl_s3_valid),
    .miu_ooe_cmpl_s3_payload(miu_ooe_cmpl_s3_payload),
    .miu_ooe_cmpl_s3_credit(miu_ooe_cmpl_s3_credit),
    .miu_ooe_cmpl_s3_stall(miu_ooe_cmpl_s3_stall),
    .miu_ooe_cmpl_wake(miu_ooe_cmpl_wake),
    .ooe_miu_retire_s0_valid(ooe_miu_retire_s0_valid),
    .ooe_miu_retire_s0_payload(ooe_miu_retire_s0_payload),
    .ooe_miu_retire_s0_credit(ooe_miu_retire_s0_credit),
    .ooe_miu_retire_s0_stall(ooe_miu_retire_s0_stall),
    .ooe_miu_retire_s1_valid(ooe_miu_retire_s1_valid),
    .ooe_miu_retire_s1_payload(ooe_miu_retire_s1_payload),
    .ooe_miu_retire_s1_credit(ooe_miu_retire_s1_credit),
    .ooe_miu_retire_s1_stall(ooe_miu_retire_s1_stall),
    .ooe_miu_retire_s2_valid(ooe_miu_retire_s2_valid),
    .ooe_miu_retire_s2_payload(ooe_miu_retire_s2_payload),
    .ooe_miu_retire_s2_credit(ooe_miu_retire_s2_credit),
    .ooe_miu_retire_s2_stall(ooe_miu_retire_s2_stall),
    .ooe_miu_retire_s3_valid(ooe_miu_retire_s3_valid),
    .ooe_miu_retire_s3_payload(ooe_miu_retire_s3_payload),
    .ooe_miu_retire_s3_credit(ooe_miu_retire_s3_credit),
    .ooe_miu_retire_s3_stall(ooe_miu_retire_s3_stall),
    .ooe_miu_retire_wake(ooe_miu_retire_wake),
    .ooe_fet_redirect_valid(ooe_fet_redirect_valid),
    .ooe_fet_redirect_payload(ooe_fet_redirect_payload),
    .ooe_fet_redirect_credit(ooe_fet_redirect_credit),
    .ooe_fet_redirect_stall(ooe_fet_redirect_stall),
    .ooe_fet_redirect_wake(ooe_fet_redirect_wake),
    .rau_ooe_alloc_valid(rau_ooe_alloc_valid),
    .rau_ooe_alloc_payload(rau_ooe_alloc_payload),
    .rau_ooe_alloc_credit(rau_ooe_alloc_credit),
    .rau_ooe_alloc_stall(rau_ooe_alloc_stall),
    .rau_ooe_alloc_wake(rau_ooe_alloc_wake),
    .ooe_rau_status_valid(ooe_rau_status_valid),
    .ooe_rau_status_payload(ooe_rau_status_payload),
    .ooe_rau_status_credit(ooe_rau_status_credit),
    .ooe_rau_status_stall(ooe_rau_status_stall),
    .ooe_rau_status_wake(ooe_rau_status_wake),
    .rau_ooe_demote_valid(rau_ooe_demote_valid),
    .rau_ooe_demote_payload(rau_ooe_demote_payload),
    .rau_ooe_demote_credit(rau_ooe_demote_credit),
    .rau_ooe_demote_stall(rau_ooe_demote_stall),
    .rau_ooe_demote_wake(rau_ooe_demote_wake),
    .ooe_rau_drained_valid(ooe_rau_drained_valid),
    .ooe_rau_drained_payload(ooe_rau_drained_payload),
    .ooe_rau_drained_credit(ooe_rau_drained_credit),
    .ooe_rau_drained_stall(ooe_rau_drained_stall),
    .ooe_rau_drained_wake(ooe_rau_drained_wake),
    .ooe_syu_bar_valid(ooe_syu_bar_valid),
    .ooe_syu_bar_payload(ooe_syu_bar_payload),
    .ooe_syu_bar_credit(ooe_syu_bar_credit),
    .ooe_syu_bar_stall(ooe_syu_bar_stall),
    .ooe_syu_bar_wake(ooe_syu_bar_wake),
    .syu_ooe_rel_valid(syu_ooe_rel_valid),
    .syu_ooe_rel_payload(syu_ooe_rel_payload),
    .syu_ooe_rel_credit(syu_ooe_rel_credit),
    .syu_ooe_rel_stall(syu_ooe_rel_stall),
    .syu_ooe_rel_wake(syu_ooe_rel_wake),
    .ooe_cru_fault_valid(ooe_cru_fault_valid),
    .ooe_cru_fault_payload(ooe_cru_fault_payload),
    .ooe_cru_fault_credit(ooe_cru_fault_credit),
    .ooe_cru_fault_stall(ooe_cru_fault_stall),
    .ooe_cru_fault_wake(ooe_cru_fault_wake)
`ifdef CCV_TRACE
    , .dec_ooe_uop_s0_tid(dec_ooe_uop_s0_tid),
      .dec_ooe_uop_s1_tid(dec_ooe_uop_s1_tid),
      .dec_ooe_uop_s2_tid(dec_ooe_uop_s2_tid),
      .dec_ooe_uop_s3_tid(dec_ooe_uop_s3_tid),
      .dec_ooe_uop_s4_tid(dec_ooe_uop_s4_tid),
      .dec_ooe_uop_s5_tid(dec_ooe_uop_s5_tid),
      .ooe_rcu_issue_s0_tid(ooe_rcu_issue_s0_tid),
      .ooe_rcu_issue_s1_tid(ooe_rcu_issue_s1_tid),
      .ooe_rcu_issue_s2_tid(ooe_rcu_issue_s2_tid),
      .ooe_rcu_issue_s3_tid(ooe_rcu_issue_s3_tid),
      .rcu_ooe_done_s0_tid(rcu_ooe_done_s0_tid),
      .rcu_ooe_done_s1_tid(rcu_ooe_done_s1_tid),
      .rcu_ooe_done_s2_tid(rcu_ooe_done_s2_tid),
      .rcu_ooe_done_s3_tid(rcu_ooe_done_s3_tid),
      .ooe_miu_memop_s0_tid(ooe_miu_memop_s0_tid),
      .ooe_miu_memop_s1_tid(ooe_miu_memop_s1_tid),
      .ooe_miu_memop_s2_tid(ooe_miu_memop_s2_tid),
      .ooe_miu_memop_s3_tid(ooe_miu_memop_s3_tid),
      .miu_ooe_cmpl_s0_tid(miu_ooe_cmpl_s0_tid),
      .miu_ooe_cmpl_s1_tid(miu_ooe_cmpl_s1_tid),
      .miu_ooe_cmpl_s2_tid(miu_ooe_cmpl_s2_tid),
      .miu_ooe_cmpl_s3_tid(miu_ooe_cmpl_s3_tid),
      .ooe_miu_retire_s0_tid(ooe_miu_retire_s0_tid),
      .ooe_miu_retire_s1_tid(ooe_miu_retire_s1_tid),
      .ooe_miu_retire_s2_tid(ooe_miu_retire_s2_tid),
      .ooe_miu_retire_s3_tid(ooe_miu_retire_s3_tid),
      .ooe_fet_redirect_tid(ooe_fet_redirect_tid),
      .rau_ooe_alloc_tid(rau_ooe_alloc_tid),
      .ooe_rau_status_tid(ooe_rau_status_tid),
      .rau_ooe_demote_tid(rau_ooe_demote_tid),
      .ooe_rau_drained_tid(ooe_rau_drained_tid),
      .ooe_syu_bar_tid(ooe_syu_bar_tid),
      .syu_ooe_rel_tid(syu_ooe_rel_tid),
      .ooe_cru_fault_tid(ooe_cru_fault_tid)
`endif
  );

  ccv_rcu u_rcu (
    .clk(rcu_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[3]),
    .kill_ack_epoch(kill_ack_epoch[6 +: 2]),
    .sleep_ok(rcu_sleep_ok),
    .csr_req(csr_reqs[147 +: 49]),
    .csr_rsp(csr_rsps[99 +: 33]),
    .csr_credit(csr_credits[3]),
    .ooe_rcu_issue_s0_valid(ooe_rcu_issue_s0_valid),
    .ooe_rcu_issue_s0_payload(ooe_rcu_issue_s0_payload),
    .ooe_rcu_issue_s0_credit(ooe_rcu_issue_s0_credit),
    .ooe_rcu_issue_s0_stall(ooe_rcu_issue_s0_stall),
    .ooe_rcu_issue_s1_valid(ooe_rcu_issue_s1_valid),
    .ooe_rcu_issue_s1_payload(ooe_rcu_issue_s1_payload),
    .ooe_rcu_issue_s1_credit(ooe_rcu_issue_s1_credit),
    .ooe_rcu_issue_s1_stall(ooe_rcu_issue_s1_stall),
    .ooe_rcu_issue_s2_valid(ooe_rcu_issue_s2_valid),
    .ooe_rcu_issue_s2_payload(ooe_rcu_issue_s2_payload),
    .ooe_rcu_issue_s2_credit(ooe_rcu_issue_s2_credit),
    .ooe_rcu_issue_s2_stall(ooe_rcu_issue_s2_stall),
    .ooe_rcu_issue_s3_valid(ooe_rcu_issue_s3_valid),
    .ooe_rcu_issue_s3_payload(ooe_rcu_issue_s3_payload),
    .ooe_rcu_issue_s3_credit(ooe_rcu_issue_s3_credit),
    .ooe_rcu_issue_s3_stall(ooe_rcu_issue_s3_stall),
    .ooe_rcu_issue_wake(ooe_rcu_issue_wake),
    .rcu_lane_ops_c00_s0_valid(rcu_lane_ops_c00_s0_valid),
    .rcu_lane_ops_c00_s0_payload(rcu_lane_ops_c00_s0_payload),
    .rcu_lane_ops_c00_s0_credit(rcu_lane_ops_c00_s0_credit),
    .rcu_lane_ops_c00_s0_stall(rcu_lane_ops_c00_s0_stall),
    .rcu_lane_ops_c00_s1_valid(rcu_lane_ops_c00_s1_valid),
    .rcu_lane_ops_c00_s1_payload(rcu_lane_ops_c00_s1_payload),
    .rcu_lane_ops_c00_s1_credit(rcu_lane_ops_c00_s1_credit),
    .rcu_lane_ops_c00_s1_stall(rcu_lane_ops_c00_s1_stall),
    .rcu_lane_ops_c00_s2_valid(rcu_lane_ops_c00_s2_valid),
    .rcu_lane_ops_c00_s2_payload(rcu_lane_ops_c00_s2_payload),
    .rcu_lane_ops_c00_s2_credit(rcu_lane_ops_c00_s2_credit),
    .rcu_lane_ops_c00_s2_stall(rcu_lane_ops_c00_s2_stall),
    .rcu_lane_ops_c00_s3_valid(rcu_lane_ops_c00_s3_valid),
    .rcu_lane_ops_c00_s3_payload(rcu_lane_ops_c00_s3_payload),
    .rcu_lane_ops_c00_s3_credit(rcu_lane_ops_c00_s3_credit),
    .rcu_lane_ops_c00_s3_stall(rcu_lane_ops_c00_s3_stall),
    .rcu_lane_ops_c00_wake(rcu_lane_ops_c00_wake),
    .rcu_lane_ops_c01_s0_valid(rcu_lane_ops_c01_s0_valid),
    .rcu_lane_ops_c01_s0_payload(rcu_lane_ops_c01_s0_payload),
    .rcu_lane_ops_c01_s0_credit(rcu_lane_ops_c01_s0_credit),
    .rcu_lane_ops_c01_s0_stall(rcu_lane_ops_c01_s0_stall),
    .rcu_lane_ops_c01_s1_valid(rcu_lane_ops_c01_s1_valid),
    .rcu_lane_ops_c01_s1_payload(rcu_lane_ops_c01_s1_payload),
    .rcu_lane_ops_c01_s1_credit(rcu_lane_ops_c01_s1_credit),
    .rcu_lane_ops_c01_s1_stall(rcu_lane_ops_c01_s1_stall),
    .rcu_lane_ops_c01_s2_valid(rcu_lane_ops_c01_s2_valid),
    .rcu_lane_ops_c01_s2_payload(rcu_lane_ops_c01_s2_payload),
    .rcu_lane_ops_c01_s2_credit(rcu_lane_ops_c01_s2_credit),
    .rcu_lane_ops_c01_s2_stall(rcu_lane_ops_c01_s2_stall),
    .rcu_lane_ops_c01_s3_valid(rcu_lane_ops_c01_s3_valid),
    .rcu_lane_ops_c01_s3_payload(rcu_lane_ops_c01_s3_payload),
    .rcu_lane_ops_c01_s3_credit(rcu_lane_ops_c01_s3_credit),
    .rcu_lane_ops_c01_s3_stall(rcu_lane_ops_c01_s3_stall),
    .rcu_lane_ops_c01_wake(rcu_lane_ops_c01_wake),
    .rcu_lane_ops_c02_s0_valid(rcu_lane_ops_c02_s0_valid),
    .rcu_lane_ops_c02_s0_payload(rcu_lane_ops_c02_s0_payload),
    .rcu_lane_ops_c02_s0_credit(rcu_lane_ops_c02_s0_credit),
    .rcu_lane_ops_c02_s0_stall(rcu_lane_ops_c02_s0_stall),
    .rcu_lane_ops_c02_s1_valid(rcu_lane_ops_c02_s1_valid),
    .rcu_lane_ops_c02_s1_payload(rcu_lane_ops_c02_s1_payload),
    .rcu_lane_ops_c02_s1_credit(rcu_lane_ops_c02_s1_credit),
    .rcu_lane_ops_c02_s1_stall(rcu_lane_ops_c02_s1_stall),
    .rcu_lane_ops_c02_s2_valid(rcu_lane_ops_c02_s2_valid),
    .rcu_lane_ops_c02_s2_payload(rcu_lane_ops_c02_s2_payload),
    .rcu_lane_ops_c02_s2_credit(rcu_lane_ops_c02_s2_credit),
    .rcu_lane_ops_c02_s2_stall(rcu_lane_ops_c02_s2_stall),
    .rcu_lane_ops_c02_s3_valid(rcu_lane_ops_c02_s3_valid),
    .rcu_lane_ops_c02_s3_payload(rcu_lane_ops_c02_s3_payload),
    .rcu_lane_ops_c02_s3_credit(rcu_lane_ops_c02_s3_credit),
    .rcu_lane_ops_c02_s3_stall(rcu_lane_ops_c02_s3_stall),
    .rcu_lane_ops_c02_wake(rcu_lane_ops_c02_wake),
    .rcu_lane_ops_c03_s0_valid(rcu_lane_ops_c03_s0_valid),
    .rcu_lane_ops_c03_s0_payload(rcu_lane_ops_c03_s0_payload),
    .rcu_lane_ops_c03_s0_credit(rcu_lane_ops_c03_s0_credit),
    .rcu_lane_ops_c03_s0_stall(rcu_lane_ops_c03_s0_stall),
    .rcu_lane_ops_c03_s1_valid(rcu_lane_ops_c03_s1_valid),
    .rcu_lane_ops_c03_s1_payload(rcu_lane_ops_c03_s1_payload),
    .rcu_lane_ops_c03_s1_credit(rcu_lane_ops_c03_s1_credit),
    .rcu_lane_ops_c03_s1_stall(rcu_lane_ops_c03_s1_stall),
    .rcu_lane_ops_c03_s2_valid(rcu_lane_ops_c03_s2_valid),
    .rcu_lane_ops_c03_s2_payload(rcu_lane_ops_c03_s2_payload),
    .rcu_lane_ops_c03_s2_credit(rcu_lane_ops_c03_s2_credit),
    .rcu_lane_ops_c03_s2_stall(rcu_lane_ops_c03_s2_stall),
    .rcu_lane_ops_c03_s3_valid(rcu_lane_ops_c03_s3_valid),
    .rcu_lane_ops_c03_s3_payload(rcu_lane_ops_c03_s3_payload),
    .rcu_lane_ops_c03_s3_credit(rcu_lane_ops_c03_s3_credit),
    .rcu_lane_ops_c03_s3_stall(rcu_lane_ops_c03_s3_stall),
    .rcu_lane_ops_c03_wake(rcu_lane_ops_c03_wake),
    .rcu_lane_ops_c04_s0_valid(rcu_lane_ops_c04_s0_valid),
    .rcu_lane_ops_c04_s0_payload(rcu_lane_ops_c04_s0_payload),
    .rcu_lane_ops_c04_s0_credit(rcu_lane_ops_c04_s0_credit),
    .rcu_lane_ops_c04_s0_stall(rcu_lane_ops_c04_s0_stall),
    .rcu_lane_ops_c04_s1_valid(rcu_lane_ops_c04_s1_valid),
    .rcu_lane_ops_c04_s1_payload(rcu_lane_ops_c04_s1_payload),
    .rcu_lane_ops_c04_s1_credit(rcu_lane_ops_c04_s1_credit),
    .rcu_lane_ops_c04_s1_stall(rcu_lane_ops_c04_s1_stall),
    .rcu_lane_ops_c04_s2_valid(rcu_lane_ops_c04_s2_valid),
    .rcu_lane_ops_c04_s2_payload(rcu_lane_ops_c04_s2_payload),
    .rcu_lane_ops_c04_s2_credit(rcu_lane_ops_c04_s2_credit),
    .rcu_lane_ops_c04_s2_stall(rcu_lane_ops_c04_s2_stall),
    .rcu_lane_ops_c04_s3_valid(rcu_lane_ops_c04_s3_valid),
    .rcu_lane_ops_c04_s3_payload(rcu_lane_ops_c04_s3_payload),
    .rcu_lane_ops_c04_s3_credit(rcu_lane_ops_c04_s3_credit),
    .rcu_lane_ops_c04_s3_stall(rcu_lane_ops_c04_s3_stall),
    .rcu_lane_ops_c04_wake(rcu_lane_ops_c04_wake),
    .rcu_lane_ops_c05_s0_valid(rcu_lane_ops_c05_s0_valid),
    .rcu_lane_ops_c05_s0_payload(rcu_lane_ops_c05_s0_payload),
    .rcu_lane_ops_c05_s0_credit(rcu_lane_ops_c05_s0_credit),
    .rcu_lane_ops_c05_s0_stall(rcu_lane_ops_c05_s0_stall),
    .rcu_lane_ops_c05_s1_valid(rcu_lane_ops_c05_s1_valid),
    .rcu_lane_ops_c05_s1_payload(rcu_lane_ops_c05_s1_payload),
    .rcu_lane_ops_c05_s1_credit(rcu_lane_ops_c05_s1_credit),
    .rcu_lane_ops_c05_s1_stall(rcu_lane_ops_c05_s1_stall),
    .rcu_lane_ops_c05_s2_valid(rcu_lane_ops_c05_s2_valid),
    .rcu_lane_ops_c05_s2_payload(rcu_lane_ops_c05_s2_payload),
    .rcu_lane_ops_c05_s2_credit(rcu_lane_ops_c05_s2_credit),
    .rcu_lane_ops_c05_s2_stall(rcu_lane_ops_c05_s2_stall),
    .rcu_lane_ops_c05_s3_valid(rcu_lane_ops_c05_s3_valid),
    .rcu_lane_ops_c05_s3_payload(rcu_lane_ops_c05_s3_payload),
    .rcu_lane_ops_c05_s3_credit(rcu_lane_ops_c05_s3_credit),
    .rcu_lane_ops_c05_s3_stall(rcu_lane_ops_c05_s3_stall),
    .rcu_lane_ops_c05_wake(rcu_lane_ops_c05_wake),
    .rcu_lane_ops_c06_s0_valid(rcu_lane_ops_c06_s0_valid),
    .rcu_lane_ops_c06_s0_payload(rcu_lane_ops_c06_s0_payload),
    .rcu_lane_ops_c06_s0_credit(rcu_lane_ops_c06_s0_credit),
    .rcu_lane_ops_c06_s0_stall(rcu_lane_ops_c06_s0_stall),
    .rcu_lane_ops_c06_s1_valid(rcu_lane_ops_c06_s1_valid),
    .rcu_lane_ops_c06_s1_payload(rcu_lane_ops_c06_s1_payload),
    .rcu_lane_ops_c06_s1_credit(rcu_lane_ops_c06_s1_credit),
    .rcu_lane_ops_c06_s1_stall(rcu_lane_ops_c06_s1_stall),
    .rcu_lane_ops_c06_s2_valid(rcu_lane_ops_c06_s2_valid),
    .rcu_lane_ops_c06_s2_payload(rcu_lane_ops_c06_s2_payload),
    .rcu_lane_ops_c06_s2_credit(rcu_lane_ops_c06_s2_credit),
    .rcu_lane_ops_c06_s2_stall(rcu_lane_ops_c06_s2_stall),
    .rcu_lane_ops_c06_s3_valid(rcu_lane_ops_c06_s3_valid),
    .rcu_lane_ops_c06_s3_payload(rcu_lane_ops_c06_s3_payload),
    .rcu_lane_ops_c06_s3_credit(rcu_lane_ops_c06_s3_credit),
    .rcu_lane_ops_c06_s3_stall(rcu_lane_ops_c06_s3_stall),
    .rcu_lane_ops_c06_wake(rcu_lane_ops_c06_wake),
    .rcu_lane_ops_c07_s0_valid(rcu_lane_ops_c07_s0_valid),
    .rcu_lane_ops_c07_s0_payload(rcu_lane_ops_c07_s0_payload),
    .rcu_lane_ops_c07_s0_credit(rcu_lane_ops_c07_s0_credit),
    .rcu_lane_ops_c07_s0_stall(rcu_lane_ops_c07_s0_stall),
    .rcu_lane_ops_c07_s1_valid(rcu_lane_ops_c07_s1_valid),
    .rcu_lane_ops_c07_s1_payload(rcu_lane_ops_c07_s1_payload),
    .rcu_lane_ops_c07_s1_credit(rcu_lane_ops_c07_s1_credit),
    .rcu_lane_ops_c07_s1_stall(rcu_lane_ops_c07_s1_stall),
    .rcu_lane_ops_c07_s2_valid(rcu_lane_ops_c07_s2_valid),
    .rcu_lane_ops_c07_s2_payload(rcu_lane_ops_c07_s2_payload),
    .rcu_lane_ops_c07_s2_credit(rcu_lane_ops_c07_s2_credit),
    .rcu_lane_ops_c07_s2_stall(rcu_lane_ops_c07_s2_stall),
    .rcu_lane_ops_c07_s3_valid(rcu_lane_ops_c07_s3_valid),
    .rcu_lane_ops_c07_s3_payload(rcu_lane_ops_c07_s3_payload),
    .rcu_lane_ops_c07_s3_credit(rcu_lane_ops_c07_s3_credit),
    .rcu_lane_ops_c07_s3_stall(rcu_lane_ops_c07_s3_stall),
    .rcu_lane_ops_c07_wake(rcu_lane_ops_c07_wake),
    .rcu_lane_ops_c08_s0_valid(rcu_lane_ops_c08_s0_valid),
    .rcu_lane_ops_c08_s0_payload(rcu_lane_ops_c08_s0_payload),
    .rcu_lane_ops_c08_s0_credit(rcu_lane_ops_c08_s0_credit),
    .rcu_lane_ops_c08_s0_stall(rcu_lane_ops_c08_s0_stall),
    .rcu_lane_ops_c08_s1_valid(rcu_lane_ops_c08_s1_valid),
    .rcu_lane_ops_c08_s1_payload(rcu_lane_ops_c08_s1_payload),
    .rcu_lane_ops_c08_s1_credit(rcu_lane_ops_c08_s1_credit),
    .rcu_lane_ops_c08_s1_stall(rcu_lane_ops_c08_s1_stall),
    .rcu_lane_ops_c08_s2_valid(rcu_lane_ops_c08_s2_valid),
    .rcu_lane_ops_c08_s2_payload(rcu_lane_ops_c08_s2_payload),
    .rcu_lane_ops_c08_s2_credit(rcu_lane_ops_c08_s2_credit),
    .rcu_lane_ops_c08_s2_stall(rcu_lane_ops_c08_s2_stall),
    .rcu_lane_ops_c08_s3_valid(rcu_lane_ops_c08_s3_valid),
    .rcu_lane_ops_c08_s3_payload(rcu_lane_ops_c08_s3_payload),
    .rcu_lane_ops_c08_s3_credit(rcu_lane_ops_c08_s3_credit),
    .rcu_lane_ops_c08_s3_stall(rcu_lane_ops_c08_s3_stall),
    .rcu_lane_ops_c08_wake(rcu_lane_ops_c08_wake),
    .rcu_lane_ops_c09_s0_valid(rcu_lane_ops_c09_s0_valid),
    .rcu_lane_ops_c09_s0_payload(rcu_lane_ops_c09_s0_payload),
    .rcu_lane_ops_c09_s0_credit(rcu_lane_ops_c09_s0_credit),
    .rcu_lane_ops_c09_s0_stall(rcu_lane_ops_c09_s0_stall),
    .rcu_lane_ops_c09_s1_valid(rcu_lane_ops_c09_s1_valid),
    .rcu_lane_ops_c09_s1_payload(rcu_lane_ops_c09_s1_payload),
    .rcu_lane_ops_c09_s1_credit(rcu_lane_ops_c09_s1_credit),
    .rcu_lane_ops_c09_s1_stall(rcu_lane_ops_c09_s1_stall),
    .rcu_lane_ops_c09_s2_valid(rcu_lane_ops_c09_s2_valid),
    .rcu_lane_ops_c09_s2_payload(rcu_lane_ops_c09_s2_payload),
    .rcu_lane_ops_c09_s2_credit(rcu_lane_ops_c09_s2_credit),
    .rcu_lane_ops_c09_s2_stall(rcu_lane_ops_c09_s2_stall),
    .rcu_lane_ops_c09_s3_valid(rcu_lane_ops_c09_s3_valid),
    .rcu_lane_ops_c09_s3_payload(rcu_lane_ops_c09_s3_payload),
    .rcu_lane_ops_c09_s3_credit(rcu_lane_ops_c09_s3_credit),
    .rcu_lane_ops_c09_s3_stall(rcu_lane_ops_c09_s3_stall),
    .rcu_lane_ops_c09_wake(rcu_lane_ops_c09_wake),
    .rcu_lane_ops_c10_s0_valid(rcu_lane_ops_c10_s0_valid),
    .rcu_lane_ops_c10_s0_payload(rcu_lane_ops_c10_s0_payload),
    .rcu_lane_ops_c10_s0_credit(rcu_lane_ops_c10_s0_credit),
    .rcu_lane_ops_c10_s0_stall(rcu_lane_ops_c10_s0_stall),
    .rcu_lane_ops_c10_s1_valid(rcu_lane_ops_c10_s1_valid),
    .rcu_lane_ops_c10_s1_payload(rcu_lane_ops_c10_s1_payload),
    .rcu_lane_ops_c10_s1_credit(rcu_lane_ops_c10_s1_credit),
    .rcu_lane_ops_c10_s1_stall(rcu_lane_ops_c10_s1_stall),
    .rcu_lane_ops_c10_s2_valid(rcu_lane_ops_c10_s2_valid),
    .rcu_lane_ops_c10_s2_payload(rcu_lane_ops_c10_s2_payload),
    .rcu_lane_ops_c10_s2_credit(rcu_lane_ops_c10_s2_credit),
    .rcu_lane_ops_c10_s2_stall(rcu_lane_ops_c10_s2_stall),
    .rcu_lane_ops_c10_s3_valid(rcu_lane_ops_c10_s3_valid),
    .rcu_lane_ops_c10_s3_payload(rcu_lane_ops_c10_s3_payload),
    .rcu_lane_ops_c10_s3_credit(rcu_lane_ops_c10_s3_credit),
    .rcu_lane_ops_c10_s3_stall(rcu_lane_ops_c10_s3_stall),
    .rcu_lane_ops_c10_wake(rcu_lane_ops_c10_wake),
    .rcu_lane_ops_c11_s0_valid(rcu_lane_ops_c11_s0_valid),
    .rcu_lane_ops_c11_s0_payload(rcu_lane_ops_c11_s0_payload),
    .rcu_lane_ops_c11_s0_credit(rcu_lane_ops_c11_s0_credit),
    .rcu_lane_ops_c11_s0_stall(rcu_lane_ops_c11_s0_stall),
    .rcu_lane_ops_c11_s1_valid(rcu_lane_ops_c11_s1_valid),
    .rcu_lane_ops_c11_s1_payload(rcu_lane_ops_c11_s1_payload),
    .rcu_lane_ops_c11_s1_credit(rcu_lane_ops_c11_s1_credit),
    .rcu_lane_ops_c11_s1_stall(rcu_lane_ops_c11_s1_stall),
    .rcu_lane_ops_c11_s2_valid(rcu_lane_ops_c11_s2_valid),
    .rcu_lane_ops_c11_s2_payload(rcu_lane_ops_c11_s2_payload),
    .rcu_lane_ops_c11_s2_credit(rcu_lane_ops_c11_s2_credit),
    .rcu_lane_ops_c11_s2_stall(rcu_lane_ops_c11_s2_stall),
    .rcu_lane_ops_c11_s3_valid(rcu_lane_ops_c11_s3_valid),
    .rcu_lane_ops_c11_s3_payload(rcu_lane_ops_c11_s3_payload),
    .rcu_lane_ops_c11_s3_credit(rcu_lane_ops_c11_s3_credit),
    .rcu_lane_ops_c11_s3_stall(rcu_lane_ops_c11_s3_stall),
    .rcu_lane_ops_c11_wake(rcu_lane_ops_c11_wake),
    .rcu_lane_ops_c12_s0_valid(rcu_lane_ops_c12_s0_valid),
    .rcu_lane_ops_c12_s0_payload(rcu_lane_ops_c12_s0_payload),
    .rcu_lane_ops_c12_s0_credit(rcu_lane_ops_c12_s0_credit),
    .rcu_lane_ops_c12_s0_stall(rcu_lane_ops_c12_s0_stall),
    .rcu_lane_ops_c12_s1_valid(rcu_lane_ops_c12_s1_valid),
    .rcu_lane_ops_c12_s1_payload(rcu_lane_ops_c12_s1_payload),
    .rcu_lane_ops_c12_s1_credit(rcu_lane_ops_c12_s1_credit),
    .rcu_lane_ops_c12_s1_stall(rcu_lane_ops_c12_s1_stall),
    .rcu_lane_ops_c12_s2_valid(rcu_lane_ops_c12_s2_valid),
    .rcu_lane_ops_c12_s2_payload(rcu_lane_ops_c12_s2_payload),
    .rcu_lane_ops_c12_s2_credit(rcu_lane_ops_c12_s2_credit),
    .rcu_lane_ops_c12_s2_stall(rcu_lane_ops_c12_s2_stall),
    .rcu_lane_ops_c12_s3_valid(rcu_lane_ops_c12_s3_valid),
    .rcu_lane_ops_c12_s3_payload(rcu_lane_ops_c12_s3_payload),
    .rcu_lane_ops_c12_s3_credit(rcu_lane_ops_c12_s3_credit),
    .rcu_lane_ops_c12_s3_stall(rcu_lane_ops_c12_s3_stall),
    .rcu_lane_ops_c12_wake(rcu_lane_ops_c12_wake),
    .rcu_lane_ops_c13_s0_valid(rcu_lane_ops_c13_s0_valid),
    .rcu_lane_ops_c13_s0_payload(rcu_lane_ops_c13_s0_payload),
    .rcu_lane_ops_c13_s0_credit(rcu_lane_ops_c13_s0_credit),
    .rcu_lane_ops_c13_s0_stall(rcu_lane_ops_c13_s0_stall),
    .rcu_lane_ops_c13_s1_valid(rcu_lane_ops_c13_s1_valid),
    .rcu_lane_ops_c13_s1_payload(rcu_lane_ops_c13_s1_payload),
    .rcu_lane_ops_c13_s1_credit(rcu_lane_ops_c13_s1_credit),
    .rcu_lane_ops_c13_s1_stall(rcu_lane_ops_c13_s1_stall),
    .rcu_lane_ops_c13_s2_valid(rcu_lane_ops_c13_s2_valid),
    .rcu_lane_ops_c13_s2_payload(rcu_lane_ops_c13_s2_payload),
    .rcu_lane_ops_c13_s2_credit(rcu_lane_ops_c13_s2_credit),
    .rcu_lane_ops_c13_s2_stall(rcu_lane_ops_c13_s2_stall),
    .rcu_lane_ops_c13_s3_valid(rcu_lane_ops_c13_s3_valid),
    .rcu_lane_ops_c13_s3_payload(rcu_lane_ops_c13_s3_payload),
    .rcu_lane_ops_c13_s3_credit(rcu_lane_ops_c13_s3_credit),
    .rcu_lane_ops_c13_s3_stall(rcu_lane_ops_c13_s3_stall),
    .rcu_lane_ops_c13_wake(rcu_lane_ops_c13_wake),
    .rcu_lane_ops_c14_s0_valid(rcu_lane_ops_c14_s0_valid),
    .rcu_lane_ops_c14_s0_payload(rcu_lane_ops_c14_s0_payload),
    .rcu_lane_ops_c14_s0_credit(rcu_lane_ops_c14_s0_credit),
    .rcu_lane_ops_c14_s0_stall(rcu_lane_ops_c14_s0_stall),
    .rcu_lane_ops_c14_s1_valid(rcu_lane_ops_c14_s1_valid),
    .rcu_lane_ops_c14_s1_payload(rcu_lane_ops_c14_s1_payload),
    .rcu_lane_ops_c14_s1_credit(rcu_lane_ops_c14_s1_credit),
    .rcu_lane_ops_c14_s1_stall(rcu_lane_ops_c14_s1_stall),
    .rcu_lane_ops_c14_s2_valid(rcu_lane_ops_c14_s2_valid),
    .rcu_lane_ops_c14_s2_payload(rcu_lane_ops_c14_s2_payload),
    .rcu_lane_ops_c14_s2_credit(rcu_lane_ops_c14_s2_credit),
    .rcu_lane_ops_c14_s2_stall(rcu_lane_ops_c14_s2_stall),
    .rcu_lane_ops_c14_s3_valid(rcu_lane_ops_c14_s3_valid),
    .rcu_lane_ops_c14_s3_payload(rcu_lane_ops_c14_s3_payload),
    .rcu_lane_ops_c14_s3_credit(rcu_lane_ops_c14_s3_credit),
    .rcu_lane_ops_c14_s3_stall(rcu_lane_ops_c14_s3_stall),
    .rcu_lane_ops_c14_wake(rcu_lane_ops_c14_wake),
    .rcu_lane_ops_c15_s0_valid(rcu_lane_ops_c15_s0_valid),
    .rcu_lane_ops_c15_s0_payload(rcu_lane_ops_c15_s0_payload),
    .rcu_lane_ops_c15_s0_credit(rcu_lane_ops_c15_s0_credit),
    .rcu_lane_ops_c15_s0_stall(rcu_lane_ops_c15_s0_stall),
    .rcu_lane_ops_c15_s1_valid(rcu_lane_ops_c15_s1_valid),
    .rcu_lane_ops_c15_s1_payload(rcu_lane_ops_c15_s1_payload),
    .rcu_lane_ops_c15_s1_credit(rcu_lane_ops_c15_s1_credit),
    .rcu_lane_ops_c15_s1_stall(rcu_lane_ops_c15_s1_stall),
    .rcu_lane_ops_c15_s2_valid(rcu_lane_ops_c15_s2_valid),
    .rcu_lane_ops_c15_s2_payload(rcu_lane_ops_c15_s2_payload),
    .rcu_lane_ops_c15_s2_credit(rcu_lane_ops_c15_s2_credit),
    .rcu_lane_ops_c15_s2_stall(rcu_lane_ops_c15_s2_stall),
    .rcu_lane_ops_c15_s3_valid(rcu_lane_ops_c15_s3_valid),
    .rcu_lane_ops_c15_s3_payload(rcu_lane_ops_c15_s3_payload),
    .rcu_lane_ops_c15_s3_credit(rcu_lane_ops_c15_s3_credit),
    .rcu_lane_ops_c15_s3_stall(rcu_lane_ops_c15_s3_stall),
    .rcu_lane_ops_c15_wake(rcu_lane_ops_c15_wake),
    .rcu_lane_ops_c16_s0_valid(rcu_lane_ops_c16_s0_valid),
    .rcu_lane_ops_c16_s0_payload(rcu_lane_ops_c16_s0_payload),
    .rcu_lane_ops_c16_s0_credit(rcu_lane_ops_c16_s0_credit),
    .rcu_lane_ops_c16_s0_stall(rcu_lane_ops_c16_s0_stall),
    .rcu_lane_ops_c16_s1_valid(rcu_lane_ops_c16_s1_valid),
    .rcu_lane_ops_c16_s1_payload(rcu_lane_ops_c16_s1_payload),
    .rcu_lane_ops_c16_s1_credit(rcu_lane_ops_c16_s1_credit),
    .rcu_lane_ops_c16_s1_stall(rcu_lane_ops_c16_s1_stall),
    .rcu_lane_ops_c16_s2_valid(rcu_lane_ops_c16_s2_valid),
    .rcu_lane_ops_c16_s2_payload(rcu_lane_ops_c16_s2_payload),
    .rcu_lane_ops_c16_s2_credit(rcu_lane_ops_c16_s2_credit),
    .rcu_lane_ops_c16_s2_stall(rcu_lane_ops_c16_s2_stall),
    .rcu_lane_ops_c16_s3_valid(rcu_lane_ops_c16_s3_valid),
    .rcu_lane_ops_c16_s3_payload(rcu_lane_ops_c16_s3_payload),
    .rcu_lane_ops_c16_s3_credit(rcu_lane_ops_c16_s3_credit),
    .rcu_lane_ops_c16_s3_stall(rcu_lane_ops_c16_s3_stall),
    .rcu_lane_ops_c16_wake(rcu_lane_ops_c16_wake),
    .rcu_lane_ops_c17_s0_valid(rcu_lane_ops_c17_s0_valid),
    .rcu_lane_ops_c17_s0_payload(rcu_lane_ops_c17_s0_payload),
    .rcu_lane_ops_c17_s0_credit(rcu_lane_ops_c17_s0_credit),
    .rcu_lane_ops_c17_s0_stall(rcu_lane_ops_c17_s0_stall),
    .rcu_lane_ops_c17_s1_valid(rcu_lane_ops_c17_s1_valid),
    .rcu_lane_ops_c17_s1_payload(rcu_lane_ops_c17_s1_payload),
    .rcu_lane_ops_c17_s1_credit(rcu_lane_ops_c17_s1_credit),
    .rcu_lane_ops_c17_s1_stall(rcu_lane_ops_c17_s1_stall),
    .rcu_lane_ops_c17_s2_valid(rcu_lane_ops_c17_s2_valid),
    .rcu_lane_ops_c17_s2_payload(rcu_lane_ops_c17_s2_payload),
    .rcu_lane_ops_c17_s2_credit(rcu_lane_ops_c17_s2_credit),
    .rcu_lane_ops_c17_s2_stall(rcu_lane_ops_c17_s2_stall),
    .rcu_lane_ops_c17_s3_valid(rcu_lane_ops_c17_s3_valid),
    .rcu_lane_ops_c17_s3_payload(rcu_lane_ops_c17_s3_payload),
    .rcu_lane_ops_c17_s3_credit(rcu_lane_ops_c17_s3_credit),
    .rcu_lane_ops_c17_s3_stall(rcu_lane_ops_c17_s3_stall),
    .rcu_lane_ops_c17_wake(rcu_lane_ops_c17_wake),
    .rcu_lane_ops_c18_s0_valid(rcu_lane_ops_c18_s0_valid),
    .rcu_lane_ops_c18_s0_payload(rcu_lane_ops_c18_s0_payload),
    .rcu_lane_ops_c18_s0_credit(rcu_lane_ops_c18_s0_credit),
    .rcu_lane_ops_c18_s0_stall(rcu_lane_ops_c18_s0_stall),
    .rcu_lane_ops_c18_s1_valid(rcu_lane_ops_c18_s1_valid),
    .rcu_lane_ops_c18_s1_payload(rcu_lane_ops_c18_s1_payload),
    .rcu_lane_ops_c18_s1_credit(rcu_lane_ops_c18_s1_credit),
    .rcu_lane_ops_c18_s1_stall(rcu_lane_ops_c18_s1_stall),
    .rcu_lane_ops_c18_s2_valid(rcu_lane_ops_c18_s2_valid),
    .rcu_lane_ops_c18_s2_payload(rcu_lane_ops_c18_s2_payload),
    .rcu_lane_ops_c18_s2_credit(rcu_lane_ops_c18_s2_credit),
    .rcu_lane_ops_c18_s2_stall(rcu_lane_ops_c18_s2_stall),
    .rcu_lane_ops_c18_s3_valid(rcu_lane_ops_c18_s3_valid),
    .rcu_lane_ops_c18_s3_payload(rcu_lane_ops_c18_s3_payload),
    .rcu_lane_ops_c18_s3_credit(rcu_lane_ops_c18_s3_credit),
    .rcu_lane_ops_c18_s3_stall(rcu_lane_ops_c18_s3_stall),
    .rcu_lane_ops_c18_wake(rcu_lane_ops_c18_wake),
    .rcu_lane_ops_c19_s0_valid(rcu_lane_ops_c19_s0_valid),
    .rcu_lane_ops_c19_s0_payload(rcu_lane_ops_c19_s0_payload),
    .rcu_lane_ops_c19_s0_credit(rcu_lane_ops_c19_s0_credit),
    .rcu_lane_ops_c19_s0_stall(rcu_lane_ops_c19_s0_stall),
    .rcu_lane_ops_c19_s1_valid(rcu_lane_ops_c19_s1_valid),
    .rcu_lane_ops_c19_s1_payload(rcu_lane_ops_c19_s1_payload),
    .rcu_lane_ops_c19_s1_credit(rcu_lane_ops_c19_s1_credit),
    .rcu_lane_ops_c19_s1_stall(rcu_lane_ops_c19_s1_stall),
    .rcu_lane_ops_c19_s2_valid(rcu_lane_ops_c19_s2_valid),
    .rcu_lane_ops_c19_s2_payload(rcu_lane_ops_c19_s2_payload),
    .rcu_lane_ops_c19_s2_credit(rcu_lane_ops_c19_s2_credit),
    .rcu_lane_ops_c19_s2_stall(rcu_lane_ops_c19_s2_stall),
    .rcu_lane_ops_c19_s3_valid(rcu_lane_ops_c19_s3_valid),
    .rcu_lane_ops_c19_s3_payload(rcu_lane_ops_c19_s3_payload),
    .rcu_lane_ops_c19_s3_credit(rcu_lane_ops_c19_s3_credit),
    .rcu_lane_ops_c19_s3_stall(rcu_lane_ops_c19_s3_stall),
    .rcu_lane_ops_c19_wake(rcu_lane_ops_c19_wake),
    .rcu_lane_ops_c20_s0_valid(rcu_lane_ops_c20_s0_valid),
    .rcu_lane_ops_c20_s0_payload(rcu_lane_ops_c20_s0_payload),
    .rcu_lane_ops_c20_s0_credit(rcu_lane_ops_c20_s0_credit),
    .rcu_lane_ops_c20_s0_stall(rcu_lane_ops_c20_s0_stall),
    .rcu_lane_ops_c20_s1_valid(rcu_lane_ops_c20_s1_valid),
    .rcu_lane_ops_c20_s1_payload(rcu_lane_ops_c20_s1_payload),
    .rcu_lane_ops_c20_s1_credit(rcu_lane_ops_c20_s1_credit),
    .rcu_lane_ops_c20_s1_stall(rcu_lane_ops_c20_s1_stall),
    .rcu_lane_ops_c20_s2_valid(rcu_lane_ops_c20_s2_valid),
    .rcu_lane_ops_c20_s2_payload(rcu_lane_ops_c20_s2_payload),
    .rcu_lane_ops_c20_s2_credit(rcu_lane_ops_c20_s2_credit),
    .rcu_lane_ops_c20_s2_stall(rcu_lane_ops_c20_s2_stall),
    .rcu_lane_ops_c20_s3_valid(rcu_lane_ops_c20_s3_valid),
    .rcu_lane_ops_c20_s3_payload(rcu_lane_ops_c20_s3_payload),
    .rcu_lane_ops_c20_s3_credit(rcu_lane_ops_c20_s3_credit),
    .rcu_lane_ops_c20_s3_stall(rcu_lane_ops_c20_s3_stall),
    .rcu_lane_ops_c20_wake(rcu_lane_ops_c20_wake),
    .rcu_lane_ops_c21_s0_valid(rcu_lane_ops_c21_s0_valid),
    .rcu_lane_ops_c21_s0_payload(rcu_lane_ops_c21_s0_payload),
    .rcu_lane_ops_c21_s0_credit(rcu_lane_ops_c21_s0_credit),
    .rcu_lane_ops_c21_s0_stall(rcu_lane_ops_c21_s0_stall),
    .rcu_lane_ops_c21_s1_valid(rcu_lane_ops_c21_s1_valid),
    .rcu_lane_ops_c21_s1_payload(rcu_lane_ops_c21_s1_payload),
    .rcu_lane_ops_c21_s1_credit(rcu_lane_ops_c21_s1_credit),
    .rcu_lane_ops_c21_s1_stall(rcu_lane_ops_c21_s1_stall),
    .rcu_lane_ops_c21_s2_valid(rcu_lane_ops_c21_s2_valid),
    .rcu_lane_ops_c21_s2_payload(rcu_lane_ops_c21_s2_payload),
    .rcu_lane_ops_c21_s2_credit(rcu_lane_ops_c21_s2_credit),
    .rcu_lane_ops_c21_s2_stall(rcu_lane_ops_c21_s2_stall),
    .rcu_lane_ops_c21_s3_valid(rcu_lane_ops_c21_s3_valid),
    .rcu_lane_ops_c21_s3_payload(rcu_lane_ops_c21_s3_payload),
    .rcu_lane_ops_c21_s3_credit(rcu_lane_ops_c21_s3_credit),
    .rcu_lane_ops_c21_s3_stall(rcu_lane_ops_c21_s3_stall),
    .rcu_lane_ops_c21_wake(rcu_lane_ops_c21_wake),
    .rcu_lane_ops_c22_s0_valid(rcu_lane_ops_c22_s0_valid),
    .rcu_lane_ops_c22_s0_payload(rcu_lane_ops_c22_s0_payload),
    .rcu_lane_ops_c22_s0_credit(rcu_lane_ops_c22_s0_credit),
    .rcu_lane_ops_c22_s0_stall(rcu_lane_ops_c22_s0_stall),
    .rcu_lane_ops_c22_s1_valid(rcu_lane_ops_c22_s1_valid),
    .rcu_lane_ops_c22_s1_payload(rcu_lane_ops_c22_s1_payload),
    .rcu_lane_ops_c22_s1_credit(rcu_lane_ops_c22_s1_credit),
    .rcu_lane_ops_c22_s1_stall(rcu_lane_ops_c22_s1_stall),
    .rcu_lane_ops_c22_s2_valid(rcu_lane_ops_c22_s2_valid),
    .rcu_lane_ops_c22_s2_payload(rcu_lane_ops_c22_s2_payload),
    .rcu_lane_ops_c22_s2_credit(rcu_lane_ops_c22_s2_credit),
    .rcu_lane_ops_c22_s2_stall(rcu_lane_ops_c22_s2_stall),
    .rcu_lane_ops_c22_s3_valid(rcu_lane_ops_c22_s3_valid),
    .rcu_lane_ops_c22_s3_payload(rcu_lane_ops_c22_s3_payload),
    .rcu_lane_ops_c22_s3_credit(rcu_lane_ops_c22_s3_credit),
    .rcu_lane_ops_c22_s3_stall(rcu_lane_ops_c22_s3_stall),
    .rcu_lane_ops_c22_wake(rcu_lane_ops_c22_wake),
    .rcu_lane_ops_c23_s0_valid(rcu_lane_ops_c23_s0_valid),
    .rcu_lane_ops_c23_s0_payload(rcu_lane_ops_c23_s0_payload),
    .rcu_lane_ops_c23_s0_credit(rcu_lane_ops_c23_s0_credit),
    .rcu_lane_ops_c23_s0_stall(rcu_lane_ops_c23_s0_stall),
    .rcu_lane_ops_c23_s1_valid(rcu_lane_ops_c23_s1_valid),
    .rcu_lane_ops_c23_s1_payload(rcu_lane_ops_c23_s1_payload),
    .rcu_lane_ops_c23_s1_credit(rcu_lane_ops_c23_s1_credit),
    .rcu_lane_ops_c23_s1_stall(rcu_lane_ops_c23_s1_stall),
    .rcu_lane_ops_c23_s2_valid(rcu_lane_ops_c23_s2_valid),
    .rcu_lane_ops_c23_s2_payload(rcu_lane_ops_c23_s2_payload),
    .rcu_lane_ops_c23_s2_credit(rcu_lane_ops_c23_s2_credit),
    .rcu_lane_ops_c23_s2_stall(rcu_lane_ops_c23_s2_stall),
    .rcu_lane_ops_c23_s3_valid(rcu_lane_ops_c23_s3_valid),
    .rcu_lane_ops_c23_s3_payload(rcu_lane_ops_c23_s3_payload),
    .rcu_lane_ops_c23_s3_credit(rcu_lane_ops_c23_s3_credit),
    .rcu_lane_ops_c23_s3_stall(rcu_lane_ops_c23_s3_stall),
    .rcu_lane_ops_c23_wake(rcu_lane_ops_c23_wake),
    .rcu_lane_ops_c24_s0_valid(rcu_lane_ops_c24_s0_valid),
    .rcu_lane_ops_c24_s0_payload(rcu_lane_ops_c24_s0_payload),
    .rcu_lane_ops_c24_s0_credit(rcu_lane_ops_c24_s0_credit),
    .rcu_lane_ops_c24_s0_stall(rcu_lane_ops_c24_s0_stall),
    .rcu_lane_ops_c24_s1_valid(rcu_lane_ops_c24_s1_valid),
    .rcu_lane_ops_c24_s1_payload(rcu_lane_ops_c24_s1_payload),
    .rcu_lane_ops_c24_s1_credit(rcu_lane_ops_c24_s1_credit),
    .rcu_lane_ops_c24_s1_stall(rcu_lane_ops_c24_s1_stall),
    .rcu_lane_ops_c24_s2_valid(rcu_lane_ops_c24_s2_valid),
    .rcu_lane_ops_c24_s2_payload(rcu_lane_ops_c24_s2_payload),
    .rcu_lane_ops_c24_s2_credit(rcu_lane_ops_c24_s2_credit),
    .rcu_lane_ops_c24_s2_stall(rcu_lane_ops_c24_s2_stall),
    .rcu_lane_ops_c24_s3_valid(rcu_lane_ops_c24_s3_valid),
    .rcu_lane_ops_c24_s3_payload(rcu_lane_ops_c24_s3_payload),
    .rcu_lane_ops_c24_s3_credit(rcu_lane_ops_c24_s3_credit),
    .rcu_lane_ops_c24_s3_stall(rcu_lane_ops_c24_s3_stall),
    .rcu_lane_ops_c24_wake(rcu_lane_ops_c24_wake),
    .rcu_lane_ops_c25_s0_valid(rcu_lane_ops_c25_s0_valid),
    .rcu_lane_ops_c25_s0_payload(rcu_lane_ops_c25_s0_payload),
    .rcu_lane_ops_c25_s0_credit(rcu_lane_ops_c25_s0_credit),
    .rcu_lane_ops_c25_s0_stall(rcu_lane_ops_c25_s0_stall),
    .rcu_lane_ops_c25_s1_valid(rcu_lane_ops_c25_s1_valid),
    .rcu_lane_ops_c25_s1_payload(rcu_lane_ops_c25_s1_payload),
    .rcu_lane_ops_c25_s1_credit(rcu_lane_ops_c25_s1_credit),
    .rcu_lane_ops_c25_s1_stall(rcu_lane_ops_c25_s1_stall),
    .rcu_lane_ops_c25_s2_valid(rcu_lane_ops_c25_s2_valid),
    .rcu_lane_ops_c25_s2_payload(rcu_lane_ops_c25_s2_payload),
    .rcu_lane_ops_c25_s2_credit(rcu_lane_ops_c25_s2_credit),
    .rcu_lane_ops_c25_s2_stall(rcu_lane_ops_c25_s2_stall),
    .rcu_lane_ops_c25_s3_valid(rcu_lane_ops_c25_s3_valid),
    .rcu_lane_ops_c25_s3_payload(rcu_lane_ops_c25_s3_payload),
    .rcu_lane_ops_c25_s3_credit(rcu_lane_ops_c25_s3_credit),
    .rcu_lane_ops_c25_s3_stall(rcu_lane_ops_c25_s3_stall),
    .rcu_lane_ops_c25_wake(rcu_lane_ops_c25_wake),
    .rcu_lane_ops_c26_s0_valid(rcu_lane_ops_c26_s0_valid),
    .rcu_lane_ops_c26_s0_payload(rcu_lane_ops_c26_s0_payload),
    .rcu_lane_ops_c26_s0_credit(rcu_lane_ops_c26_s0_credit),
    .rcu_lane_ops_c26_s0_stall(rcu_lane_ops_c26_s0_stall),
    .rcu_lane_ops_c26_s1_valid(rcu_lane_ops_c26_s1_valid),
    .rcu_lane_ops_c26_s1_payload(rcu_lane_ops_c26_s1_payload),
    .rcu_lane_ops_c26_s1_credit(rcu_lane_ops_c26_s1_credit),
    .rcu_lane_ops_c26_s1_stall(rcu_lane_ops_c26_s1_stall),
    .rcu_lane_ops_c26_s2_valid(rcu_lane_ops_c26_s2_valid),
    .rcu_lane_ops_c26_s2_payload(rcu_lane_ops_c26_s2_payload),
    .rcu_lane_ops_c26_s2_credit(rcu_lane_ops_c26_s2_credit),
    .rcu_lane_ops_c26_s2_stall(rcu_lane_ops_c26_s2_stall),
    .rcu_lane_ops_c26_s3_valid(rcu_lane_ops_c26_s3_valid),
    .rcu_lane_ops_c26_s3_payload(rcu_lane_ops_c26_s3_payload),
    .rcu_lane_ops_c26_s3_credit(rcu_lane_ops_c26_s3_credit),
    .rcu_lane_ops_c26_s3_stall(rcu_lane_ops_c26_s3_stall),
    .rcu_lane_ops_c26_wake(rcu_lane_ops_c26_wake),
    .rcu_lane_ops_c27_s0_valid(rcu_lane_ops_c27_s0_valid),
    .rcu_lane_ops_c27_s0_payload(rcu_lane_ops_c27_s0_payload),
    .rcu_lane_ops_c27_s0_credit(rcu_lane_ops_c27_s0_credit),
    .rcu_lane_ops_c27_s0_stall(rcu_lane_ops_c27_s0_stall),
    .rcu_lane_ops_c27_s1_valid(rcu_lane_ops_c27_s1_valid),
    .rcu_lane_ops_c27_s1_payload(rcu_lane_ops_c27_s1_payload),
    .rcu_lane_ops_c27_s1_credit(rcu_lane_ops_c27_s1_credit),
    .rcu_lane_ops_c27_s1_stall(rcu_lane_ops_c27_s1_stall),
    .rcu_lane_ops_c27_s2_valid(rcu_lane_ops_c27_s2_valid),
    .rcu_lane_ops_c27_s2_payload(rcu_lane_ops_c27_s2_payload),
    .rcu_lane_ops_c27_s2_credit(rcu_lane_ops_c27_s2_credit),
    .rcu_lane_ops_c27_s2_stall(rcu_lane_ops_c27_s2_stall),
    .rcu_lane_ops_c27_s3_valid(rcu_lane_ops_c27_s3_valid),
    .rcu_lane_ops_c27_s3_payload(rcu_lane_ops_c27_s3_payload),
    .rcu_lane_ops_c27_s3_credit(rcu_lane_ops_c27_s3_credit),
    .rcu_lane_ops_c27_s3_stall(rcu_lane_ops_c27_s3_stall),
    .rcu_lane_ops_c27_wake(rcu_lane_ops_c27_wake),
    .rcu_lane_ops_c28_s0_valid(rcu_lane_ops_c28_s0_valid),
    .rcu_lane_ops_c28_s0_payload(rcu_lane_ops_c28_s0_payload),
    .rcu_lane_ops_c28_s0_credit(rcu_lane_ops_c28_s0_credit),
    .rcu_lane_ops_c28_s0_stall(rcu_lane_ops_c28_s0_stall),
    .rcu_lane_ops_c28_s1_valid(rcu_lane_ops_c28_s1_valid),
    .rcu_lane_ops_c28_s1_payload(rcu_lane_ops_c28_s1_payload),
    .rcu_lane_ops_c28_s1_credit(rcu_lane_ops_c28_s1_credit),
    .rcu_lane_ops_c28_s1_stall(rcu_lane_ops_c28_s1_stall),
    .rcu_lane_ops_c28_s2_valid(rcu_lane_ops_c28_s2_valid),
    .rcu_lane_ops_c28_s2_payload(rcu_lane_ops_c28_s2_payload),
    .rcu_lane_ops_c28_s2_credit(rcu_lane_ops_c28_s2_credit),
    .rcu_lane_ops_c28_s2_stall(rcu_lane_ops_c28_s2_stall),
    .rcu_lane_ops_c28_s3_valid(rcu_lane_ops_c28_s3_valid),
    .rcu_lane_ops_c28_s3_payload(rcu_lane_ops_c28_s3_payload),
    .rcu_lane_ops_c28_s3_credit(rcu_lane_ops_c28_s3_credit),
    .rcu_lane_ops_c28_s3_stall(rcu_lane_ops_c28_s3_stall),
    .rcu_lane_ops_c28_wake(rcu_lane_ops_c28_wake),
    .rcu_lane_ops_c29_s0_valid(rcu_lane_ops_c29_s0_valid),
    .rcu_lane_ops_c29_s0_payload(rcu_lane_ops_c29_s0_payload),
    .rcu_lane_ops_c29_s0_credit(rcu_lane_ops_c29_s0_credit),
    .rcu_lane_ops_c29_s0_stall(rcu_lane_ops_c29_s0_stall),
    .rcu_lane_ops_c29_s1_valid(rcu_lane_ops_c29_s1_valid),
    .rcu_lane_ops_c29_s1_payload(rcu_lane_ops_c29_s1_payload),
    .rcu_lane_ops_c29_s1_credit(rcu_lane_ops_c29_s1_credit),
    .rcu_lane_ops_c29_s1_stall(rcu_lane_ops_c29_s1_stall),
    .rcu_lane_ops_c29_s2_valid(rcu_lane_ops_c29_s2_valid),
    .rcu_lane_ops_c29_s2_payload(rcu_lane_ops_c29_s2_payload),
    .rcu_lane_ops_c29_s2_credit(rcu_lane_ops_c29_s2_credit),
    .rcu_lane_ops_c29_s2_stall(rcu_lane_ops_c29_s2_stall),
    .rcu_lane_ops_c29_s3_valid(rcu_lane_ops_c29_s3_valid),
    .rcu_lane_ops_c29_s3_payload(rcu_lane_ops_c29_s3_payload),
    .rcu_lane_ops_c29_s3_credit(rcu_lane_ops_c29_s3_credit),
    .rcu_lane_ops_c29_s3_stall(rcu_lane_ops_c29_s3_stall),
    .rcu_lane_ops_c29_wake(rcu_lane_ops_c29_wake),
    .rcu_lane_ops_c30_s0_valid(rcu_lane_ops_c30_s0_valid),
    .rcu_lane_ops_c30_s0_payload(rcu_lane_ops_c30_s0_payload),
    .rcu_lane_ops_c30_s0_credit(rcu_lane_ops_c30_s0_credit),
    .rcu_lane_ops_c30_s0_stall(rcu_lane_ops_c30_s0_stall),
    .rcu_lane_ops_c30_s1_valid(rcu_lane_ops_c30_s1_valid),
    .rcu_lane_ops_c30_s1_payload(rcu_lane_ops_c30_s1_payload),
    .rcu_lane_ops_c30_s1_credit(rcu_lane_ops_c30_s1_credit),
    .rcu_lane_ops_c30_s1_stall(rcu_lane_ops_c30_s1_stall),
    .rcu_lane_ops_c30_s2_valid(rcu_lane_ops_c30_s2_valid),
    .rcu_lane_ops_c30_s2_payload(rcu_lane_ops_c30_s2_payload),
    .rcu_lane_ops_c30_s2_credit(rcu_lane_ops_c30_s2_credit),
    .rcu_lane_ops_c30_s2_stall(rcu_lane_ops_c30_s2_stall),
    .rcu_lane_ops_c30_s3_valid(rcu_lane_ops_c30_s3_valid),
    .rcu_lane_ops_c30_s3_payload(rcu_lane_ops_c30_s3_payload),
    .rcu_lane_ops_c30_s3_credit(rcu_lane_ops_c30_s3_credit),
    .rcu_lane_ops_c30_s3_stall(rcu_lane_ops_c30_s3_stall),
    .rcu_lane_ops_c30_wake(rcu_lane_ops_c30_wake),
    .rcu_lane_ops_c31_s0_valid(rcu_lane_ops_c31_s0_valid),
    .rcu_lane_ops_c31_s0_payload(rcu_lane_ops_c31_s0_payload),
    .rcu_lane_ops_c31_s0_credit(rcu_lane_ops_c31_s0_credit),
    .rcu_lane_ops_c31_s0_stall(rcu_lane_ops_c31_s0_stall),
    .rcu_lane_ops_c31_s1_valid(rcu_lane_ops_c31_s1_valid),
    .rcu_lane_ops_c31_s1_payload(rcu_lane_ops_c31_s1_payload),
    .rcu_lane_ops_c31_s1_credit(rcu_lane_ops_c31_s1_credit),
    .rcu_lane_ops_c31_s1_stall(rcu_lane_ops_c31_s1_stall),
    .rcu_lane_ops_c31_s2_valid(rcu_lane_ops_c31_s2_valid),
    .rcu_lane_ops_c31_s2_payload(rcu_lane_ops_c31_s2_payload),
    .rcu_lane_ops_c31_s2_credit(rcu_lane_ops_c31_s2_credit),
    .rcu_lane_ops_c31_s2_stall(rcu_lane_ops_c31_s2_stall),
    .rcu_lane_ops_c31_s3_valid(rcu_lane_ops_c31_s3_valid),
    .rcu_lane_ops_c31_s3_payload(rcu_lane_ops_c31_s3_payload),
    .rcu_lane_ops_c31_s3_credit(rcu_lane_ops_c31_s3_credit),
    .rcu_lane_ops_c31_s3_stall(rcu_lane_ops_c31_s3_stall),
    .rcu_lane_ops_c31_wake(rcu_lane_ops_c31_wake),
    .lane_rcu_res_c00_s0_valid(lane_rcu_res_c00_s0_valid),
    .lane_rcu_res_c00_s0_payload(lane_rcu_res_c00_s0_payload),
    .lane_rcu_res_c00_s0_credit(lane_rcu_res_c00_s0_credit),
    .lane_rcu_res_c00_s0_stall(lane_rcu_res_c00_s0_stall),
    .lane_rcu_res_c00_s1_valid(lane_rcu_res_c00_s1_valid),
    .lane_rcu_res_c00_s1_payload(lane_rcu_res_c00_s1_payload),
    .lane_rcu_res_c00_s1_credit(lane_rcu_res_c00_s1_credit),
    .lane_rcu_res_c00_s1_stall(lane_rcu_res_c00_s1_stall),
    .lane_rcu_res_c00_s2_valid(lane_rcu_res_c00_s2_valid),
    .lane_rcu_res_c00_s2_payload(lane_rcu_res_c00_s2_payload),
    .lane_rcu_res_c00_s2_credit(lane_rcu_res_c00_s2_credit),
    .lane_rcu_res_c00_s2_stall(lane_rcu_res_c00_s2_stall),
    .lane_rcu_res_c00_s3_valid(lane_rcu_res_c00_s3_valid),
    .lane_rcu_res_c00_s3_payload(lane_rcu_res_c00_s3_payload),
    .lane_rcu_res_c00_s3_credit(lane_rcu_res_c00_s3_credit),
    .lane_rcu_res_c00_s3_stall(lane_rcu_res_c00_s3_stall),
    .lane_rcu_res_c00_wake(lane_rcu_res_c00_wake),
    .lane_rcu_res_c01_s0_valid(lane_rcu_res_c01_s0_valid),
    .lane_rcu_res_c01_s0_payload(lane_rcu_res_c01_s0_payload),
    .lane_rcu_res_c01_s0_credit(lane_rcu_res_c01_s0_credit),
    .lane_rcu_res_c01_s0_stall(lane_rcu_res_c01_s0_stall),
    .lane_rcu_res_c01_s1_valid(lane_rcu_res_c01_s1_valid),
    .lane_rcu_res_c01_s1_payload(lane_rcu_res_c01_s1_payload),
    .lane_rcu_res_c01_s1_credit(lane_rcu_res_c01_s1_credit),
    .lane_rcu_res_c01_s1_stall(lane_rcu_res_c01_s1_stall),
    .lane_rcu_res_c01_s2_valid(lane_rcu_res_c01_s2_valid),
    .lane_rcu_res_c01_s2_payload(lane_rcu_res_c01_s2_payload),
    .lane_rcu_res_c01_s2_credit(lane_rcu_res_c01_s2_credit),
    .lane_rcu_res_c01_s2_stall(lane_rcu_res_c01_s2_stall),
    .lane_rcu_res_c01_s3_valid(lane_rcu_res_c01_s3_valid),
    .lane_rcu_res_c01_s3_payload(lane_rcu_res_c01_s3_payload),
    .lane_rcu_res_c01_s3_credit(lane_rcu_res_c01_s3_credit),
    .lane_rcu_res_c01_s3_stall(lane_rcu_res_c01_s3_stall),
    .lane_rcu_res_c01_wake(lane_rcu_res_c01_wake),
    .lane_rcu_res_c02_s0_valid(lane_rcu_res_c02_s0_valid),
    .lane_rcu_res_c02_s0_payload(lane_rcu_res_c02_s0_payload),
    .lane_rcu_res_c02_s0_credit(lane_rcu_res_c02_s0_credit),
    .lane_rcu_res_c02_s0_stall(lane_rcu_res_c02_s0_stall),
    .lane_rcu_res_c02_s1_valid(lane_rcu_res_c02_s1_valid),
    .lane_rcu_res_c02_s1_payload(lane_rcu_res_c02_s1_payload),
    .lane_rcu_res_c02_s1_credit(lane_rcu_res_c02_s1_credit),
    .lane_rcu_res_c02_s1_stall(lane_rcu_res_c02_s1_stall),
    .lane_rcu_res_c02_s2_valid(lane_rcu_res_c02_s2_valid),
    .lane_rcu_res_c02_s2_payload(lane_rcu_res_c02_s2_payload),
    .lane_rcu_res_c02_s2_credit(lane_rcu_res_c02_s2_credit),
    .lane_rcu_res_c02_s2_stall(lane_rcu_res_c02_s2_stall),
    .lane_rcu_res_c02_s3_valid(lane_rcu_res_c02_s3_valid),
    .lane_rcu_res_c02_s3_payload(lane_rcu_res_c02_s3_payload),
    .lane_rcu_res_c02_s3_credit(lane_rcu_res_c02_s3_credit),
    .lane_rcu_res_c02_s3_stall(lane_rcu_res_c02_s3_stall),
    .lane_rcu_res_c02_wake(lane_rcu_res_c02_wake),
    .lane_rcu_res_c03_s0_valid(lane_rcu_res_c03_s0_valid),
    .lane_rcu_res_c03_s0_payload(lane_rcu_res_c03_s0_payload),
    .lane_rcu_res_c03_s0_credit(lane_rcu_res_c03_s0_credit),
    .lane_rcu_res_c03_s0_stall(lane_rcu_res_c03_s0_stall),
    .lane_rcu_res_c03_s1_valid(lane_rcu_res_c03_s1_valid),
    .lane_rcu_res_c03_s1_payload(lane_rcu_res_c03_s1_payload),
    .lane_rcu_res_c03_s1_credit(lane_rcu_res_c03_s1_credit),
    .lane_rcu_res_c03_s1_stall(lane_rcu_res_c03_s1_stall),
    .lane_rcu_res_c03_s2_valid(lane_rcu_res_c03_s2_valid),
    .lane_rcu_res_c03_s2_payload(lane_rcu_res_c03_s2_payload),
    .lane_rcu_res_c03_s2_credit(lane_rcu_res_c03_s2_credit),
    .lane_rcu_res_c03_s2_stall(lane_rcu_res_c03_s2_stall),
    .lane_rcu_res_c03_s3_valid(lane_rcu_res_c03_s3_valid),
    .lane_rcu_res_c03_s3_payload(lane_rcu_res_c03_s3_payload),
    .lane_rcu_res_c03_s3_credit(lane_rcu_res_c03_s3_credit),
    .lane_rcu_res_c03_s3_stall(lane_rcu_res_c03_s3_stall),
    .lane_rcu_res_c03_wake(lane_rcu_res_c03_wake),
    .lane_rcu_res_c04_s0_valid(lane_rcu_res_c04_s0_valid),
    .lane_rcu_res_c04_s0_payload(lane_rcu_res_c04_s0_payload),
    .lane_rcu_res_c04_s0_credit(lane_rcu_res_c04_s0_credit),
    .lane_rcu_res_c04_s0_stall(lane_rcu_res_c04_s0_stall),
    .lane_rcu_res_c04_s1_valid(lane_rcu_res_c04_s1_valid),
    .lane_rcu_res_c04_s1_payload(lane_rcu_res_c04_s1_payload),
    .lane_rcu_res_c04_s1_credit(lane_rcu_res_c04_s1_credit),
    .lane_rcu_res_c04_s1_stall(lane_rcu_res_c04_s1_stall),
    .lane_rcu_res_c04_s2_valid(lane_rcu_res_c04_s2_valid),
    .lane_rcu_res_c04_s2_payload(lane_rcu_res_c04_s2_payload),
    .lane_rcu_res_c04_s2_credit(lane_rcu_res_c04_s2_credit),
    .lane_rcu_res_c04_s2_stall(lane_rcu_res_c04_s2_stall),
    .lane_rcu_res_c04_s3_valid(lane_rcu_res_c04_s3_valid),
    .lane_rcu_res_c04_s3_payload(lane_rcu_res_c04_s3_payload),
    .lane_rcu_res_c04_s3_credit(lane_rcu_res_c04_s3_credit),
    .lane_rcu_res_c04_s3_stall(lane_rcu_res_c04_s3_stall),
    .lane_rcu_res_c04_wake(lane_rcu_res_c04_wake),
    .lane_rcu_res_c05_s0_valid(lane_rcu_res_c05_s0_valid),
    .lane_rcu_res_c05_s0_payload(lane_rcu_res_c05_s0_payload),
    .lane_rcu_res_c05_s0_credit(lane_rcu_res_c05_s0_credit),
    .lane_rcu_res_c05_s0_stall(lane_rcu_res_c05_s0_stall),
    .lane_rcu_res_c05_s1_valid(lane_rcu_res_c05_s1_valid),
    .lane_rcu_res_c05_s1_payload(lane_rcu_res_c05_s1_payload),
    .lane_rcu_res_c05_s1_credit(lane_rcu_res_c05_s1_credit),
    .lane_rcu_res_c05_s1_stall(lane_rcu_res_c05_s1_stall),
    .lane_rcu_res_c05_s2_valid(lane_rcu_res_c05_s2_valid),
    .lane_rcu_res_c05_s2_payload(lane_rcu_res_c05_s2_payload),
    .lane_rcu_res_c05_s2_credit(lane_rcu_res_c05_s2_credit),
    .lane_rcu_res_c05_s2_stall(lane_rcu_res_c05_s2_stall),
    .lane_rcu_res_c05_s3_valid(lane_rcu_res_c05_s3_valid),
    .lane_rcu_res_c05_s3_payload(lane_rcu_res_c05_s3_payload),
    .lane_rcu_res_c05_s3_credit(lane_rcu_res_c05_s3_credit),
    .lane_rcu_res_c05_s3_stall(lane_rcu_res_c05_s3_stall),
    .lane_rcu_res_c05_wake(lane_rcu_res_c05_wake),
    .lane_rcu_res_c06_s0_valid(lane_rcu_res_c06_s0_valid),
    .lane_rcu_res_c06_s0_payload(lane_rcu_res_c06_s0_payload),
    .lane_rcu_res_c06_s0_credit(lane_rcu_res_c06_s0_credit),
    .lane_rcu_res_c06_s0_stall(lane_rcu_res_c06_s0_stall),
    .lane_rcu_res_c06_s1_valid(lane_rcu_res_c06_s1_valid),
    .lane_rcu_res_c06_s1_payload(lane_rcu_res_c06_s1_payload),
    .lane_rcu_res_c06_s1_credit(lane_rcu_res_c06_s1_credit),
    .lane_rcu_res_c06_s1_stall(lane_rcu_res_c06_s1_stall),
    .lane_rcu_res_c06_s2_valid(lane_rcu_res_c06_s2_valid),
    .lane_rcu_res_c06_s2_payload(lane_rcu_res_c06_s2_payload),
    .lane_rcu_res_c06_s2_credit(lane_rcu_res_c06_s2_credit),
    .lane_rcu_res_c06_s2_stall(lane_rcu_res_c06_s2_stall),
    .lane_rcu_res_c06_s3_valid(lane_rcu_res_c06_s3_valid),
    .lane_rcu_res_c06_s3_payload(lane_rcu_res_c06_s3_payload),
    .lane_rcu_res_c06_s3_credit(lane_rcu_res_c06_s3_credit),
    .lane_rcu_res_c06_s3_stall(lane_rcu_res_c06_s3_stall),
    .lane_rcu_res_c06_wake(lane_rcu_res_c06_wake),
    .lane_rcu_res_c07_s0_valid(lane_rcu_res_c07_s0_valid),
    .lane_rcu_res_c07_s0_payload(lane_rcu_res_c07_s0_payload),
    .lane_rcu_res_c07_s0_credit(lane_rcu_res_c07_s0_credit),
    .lane_rcu_res_c07_s0_stall(lane_rcu_res_c07_s0_stall),
    .lane_rcu_res_c07_s1_valid(lane_rcu_res_c07_s1_valid),
    .lane_rcu_res_c07_s1_payload(lane_rcu_res_c07_s1_payload),
    .lane_rcu_res_c07_s1_credit(lane_rcu_res_c07_s1_credit),
    .lane_rcu_res_c07_s1_stall(lane_rcu_res_c07_s1_stall),
    .lane_rcu_res_c07_s2_valid(lane_rcu_res_c07_s2_valid),
    .lane_rcu_res_c07_s2_payload(lane_rcu_res_c07_s2_payload),
    .lane_rcu_res_c07_s2_credit(lane_rcu_res_c07_s2_credit),
    .lane_rcu_res_c07_s2_stall(lane_rcu_res_c07_s2_stall),
    .lane_rcu_res_c07_s3_valid(lane_rcu_res_c07_s3_valid),
    .lane_rcu_res_c07_s3_payload(lane_rcu_res_c07_s3_payload),
    .lane_rcu_res_c07_s3_credit(lane_rcu_res_c07_s3_credit),
    .lane_rcu_res_c07_s3_stall(lane_rcu_res_c07_s3_stall),
    .lane_rcu_res_c07_wake(lane_rcu_res_c07_wake),
    .lane_rcu_res_c08_s0_valid(lane_rcu_res_c08_s0_valid),
    .lane_rcu_res_c08_s0_payload(lane_rcu_res_c08_s0_payload),
    .lane_rcu_res_c08_s0_credit(lane_rcu_res_c08_s0_credit),
    .lane_rcu_res_c08_s0_stall(lane_rcu_res_c08_s0_stall),
    .lane_rcu_res_c08_s1_valid(lane_rcu_res_c08_s1_valid),
    .lane_rcu_res_c08_s1_payload(lane_rcu_res_c08_s1_payload),
    .lane_rcu_res_c08_s1_credit(lane_rcu_res_c08_s1_credit),
    .lane_rcu_res_c08_s1_stall(lane_rcu_res_c08_s1_stall),
    .lane_rcu_res_c08_s2_valid(lane_rcu_res_c08_s2_valid),
    .lane_rcu_res_c08_s2_payload(lane_rcu_res_c08_s2_payload),
    .lane_rcu_res_c08_s2_credit(lane_rcu_res_c08_s2_credit),
    .lane_rcu_res_c08_s2_stall(lane_rcu_res_c08_s2_stall),
    .lane_rcu_res_c08_s3_valid(lane_rcu_res_c08_s3_valid),
    .lane_rcu_res_c08_s3_payload(lane_rcu_res_c08_s3_payload),
    .lane_rcu_res_c08_s3_credit(lane_rcu_res_c08_s3_credit),
    .lane_rcu_res_c08_s3_stall(lane_rcu_res_c08_s3_stall),
    .lane_rcu_res_c08_wake(lane_rcu_res_c08_wake),
    .lane_rcu_res_c09_s0_valid(lane_rcu_res_c09_s0_valid),
    .lane_rcu_res_c09_s0_payload(lane_rcu_res_c09_s0_payload),
    .lane_rcu_res_c09_s0_credit(lane_rcu_res_c09_s0_credit),
    .lane_rcu_res_c09_s0_stall(lane_rcu_res_c09_s0_stall),
    .lane_rcu_res_c09_s1_valid(lane_rcu_res_c09_s1_valid),
    .lane_rcu_res_c09_s1_payload(lane_rcu_res_c09_s1_payload),
    .lane_rcu_res_c09_s1_credit(lane_rcu_res_c09_s1_credit),
    .lane_rcu_res_c09_s1_stall(lane_rcu_res_c09_s1_stall),
    .lane_rcu_res_c09_s2_valid(lane_rcu_res_c09_s2_valid),
    .lane_rcu_res_c09_s2_payload(lane_rcu_res_c09_s2_payload),
    .lane_rcu_res_c09_s2_credit(lane_rcu_res_c09_s2_credit),
    .lane_rcu_res_c09_s2_stall(lane_rcu_res_c09_s2_stall),
    .lane_rcu_res_c09_s3_valid(lane_rcu_res_c09_s3_valid),
    .lane_rcu_res_c09_s3_payload(lane_rcu_res_c09_s3_payload),
    .lane_rcu_res_c09_s3_credit(lane_rcu_res_c09_s3_credit),
    .lane_rcu_res_c09_s3_stall(lane_rcu_res_c09_s3_stall),
    .lane_rcu_res_c09_wake(lane_rcu_res_c09_wake),
    .lane_rcu_res_c10_s0_valid(lane_rcu_res_c10_s0_valid),
    .lane_rcu_res_c10_s0_payload(lane_rcu_res_c10_s0_payload),
    .lane_rcu_res_c10_s0_credit(lane_rcu_res_c10_s0_credit),
    .lane_rcu_res_c10_s0_stall(lane_rcu_res_c10_s0_stall),
    .lane_rcu_res_c10_s1_valid(lane_rcu_res_c10_s1_valid),
    .lane_rcu_res_c10_s1_payload(lane_rcu_res_c10_s1_payload),
    .lane_rcu_res_c10_s1_credit(lane_rcu_res_c10_s1_credit),
    .lane_rcu_res_c10_s1_stall(lane_rcu_res_c10_s1_stall),
    .lane_rcu_res_c10_s2_valid(lane_rcu_res_c10_s2_valid),
    .lane_rcu_res_c10_s2_payload(lane_rcu_res_c10_s2_payload),
    .lane_rcu_res_c10_s2_credit(lane_rcu_res_c10_s2_credit),
    .lane_rcu_res_c10_s2_stall(lane_rcu_res_c10_s2_stall),
    .lane_rcu_res_c10_s3_valid(lane_rcu_res_c10_s3_valid),
    .lane_rcu_res_c10_s3_payload(lane_rcu_res_c10_s3_payload),
    .lane_rcu_res_c10_s3_credit(lane_rcu_res_c10_s3_credit),
    .lane_rcu_res_c10_s3_stall(lane_rcu_res_c10_s3_stall),
    .lane_rcu_res_c10_wake(lane_rcu_res_c10_wake),
    .lane_rcu_res_c11_s0_valid(lane_rcu_res_c11_s0_valid),
    .lane_rcu_res_c11_s0_payload(lane_rcu_res_c11_s0_payload),
    .lane_rcu_res_c11_s0_credit(lane_rcu_res_c11_s0_credit),
    .lane_rcu_res_c11_s0_stall(lane_rcu_res_c11_s0_stall),
    .lane_rcu_res_c11_s1_valid(lane_rcu_res_c11_s1_valid),
    .lane_rcu_res_c11_s1_payload(lane_rcu_res_c11_s1_payload),
    .lane_rcu_res_c11_s1_credit(lane_rcu_res_c11_s1_credit),
    .lane_rcu_res_c11_s1_stall(lane_rcu_res_c11_s1_stall),
    .lane_rcu_res_c11_s2_valid(lane_rcu_res_c11_s2_valid),
    .lane_rcu_res_c11_s2_payload(lane_rcu_res_c11_s2_payload),
    .lane_rcu_res_c11_s2_credit(lane_rcu_res_c11_s2_credit),
    .lane_rcu_res_c11_s2_stall(lane_rcu_res_c11_s2_stall),
    .lane_rcu_res_c11_s3_valid(lane_rcu_res_c11_s3_valid),
    .lane_rcu_res_c11_s3_payload(lane_rcu_res_c11_s3_payload),
    .lane_rcu_res_c11_s3_credit(lane_rcu_res_c11_s3_credit),
    .lane_rcu_res_c11_s3_stall(lane_rcu_res_c11_s3_stall),
    .lane_rcu_res_c11_wake(lane_rcu_res_c11_wake),
    .lane_rcu_res_c12_s0_valid(lane_rcu_res_c12_s0_valid),
    .lane_rcu_res_c12_s0_payload(lane_rcu_res_c12_s0_payload),
    .lane_rcu_res_c12_s0_credit(lane_rcu_res_c12_s0_credit),
    .lane_rcu_res_c12_s0_stall(lane_rcu_res_c12_s0_stall),
    .lane_rcu_res_c12_s1_valid(lane_rcu_res_c12_s1_valid),
    .lane_rcu_res_c12_s1_payload(lane_rcu_res_c12_s1_payload),
    .lane_rcu_res_c12_s1_credit(lane_rcu_res_c12_s1_credit),
    .lane_rcu_res_c12_s1_stall(lane_rcu_res_c12_s1_stall),
    .lane_rcu_res_c12_s2_valid(lane_rcu_res_c12_s2_valid),
    .lane_rcu_res_c12_s2_payload(lane_rcu_res_c12_s2_payload),
    .lane_rcu_res_c12_s2_credit(lane_rcu_res_c12_s2_credit),
    .lane_rcu_res_c12_s2_stall(lane_rcu_res_c12_s2_stall),
    .lane_rcu_res_c12_s3_valid(lane_rcu_res_c12_s3_valid),
    .lane_rcu_res_c12_s3_payload(lane_rcu_res_c12_s3_payload),
    .lane_rcu_res_c12_s3_credit(lane_rcu_res_c12_s3_credit),
    .lane_rcu_res_c12_s3_stall(lane_rcu_res_c12_s3_stall),
    .lane_rcu_res_c12_wake(lane_rcu_res_c12_wake),
    .lane_rcu_res_c13_s0_valid(lane_rcu_res_c13_s0_valid),
    .lane_rcu_res_c13_s0_payload(lane_rcu_res_c13_s0_payload),
    .lane_rcu_res_c13_s0_credit(lane_rcu_res_c13_s0_credit),
    .lane_rcu_res_c13_s0_stall(lane_rcu_res_c13_s0_stall),
    .lane_rcu_res_c13_s1_valid(lane_rcu_res_c13_s1_valid),
    .lane_rcu_res_c13_s1_payload(lane_rcu_res_c13_s1_payload),
    .lane_rcu_res_c13_s1_credit(lane_rcu_res_c13_s1_credit),
    .lane_rcu_res_c13_s1_stall(lane_rcu_res_c13_s1_stall),
    .lane_rcu_res_c13_s2_valid(lane_rcu_res_c13_s2_valid),
    .lane_rcu_res_c13_s2_payload(lane_rcu_res_c13_s2_payload),
    .lane_rcu_res_c13_s2_credit(lane_rcu_res_c13_s2_credit),
    .lane_rcu_res_c13_s2_stall(lane_rcu_res_c13_s2_stall),
    .lane_rcu_res_c13_s3_valid(lane_rcu_res_c13_s3_valid),
    .lane_rcu_res_c13_s3_payload(lane_rcu_res_c13_s3_payload),
    .lane_rcu_res_c13_s3_credit(lane_rcu_res_c13_s3_credit),
    .lane_rcu_res_c13_s3_stall(lane_rcu_res_c13_s3_stall),
    .lane_rcu_res_c13_wake(lane_rcu_res_c13_wake),
    .lane_rcu_res_c14_s0_valid(lane_rcu_res_c14_s0_valid),
    .lane_rcu_res_c14_s0_payload(lane_rcu_res_c14_s0_payload),
    .lane_rcu_res_c14_s0_credit(lane_rcu_res_c14_s0_credit),
    .lane_rcu_res_c14_s0_stall(lane_rcu_res_c14_s0_stall),
    .lane_rcu_res_c14_s1_valid(lane_rcu_res_c14_s1_valid),
    .lane_rcu_res_c14_s1_payload(lane_rcu_res_c14_s1_payload),
    .lane_rcu_res_c14_s1_credit(lane_rcu_res_c14_s1_credit),
    .lane_rcu_res_c14_s1_stall(lane_rcu_res_c14_s1_stall),
    .lane_rcu_res_c14_s2_valid(lane_rcu_res_c14_s2_valid),
    .lane_rcu_res_c14_s2_payload(lane_rcu_res_c14_s2_payload),
    .lane_rcu_res_c14_s2_credit(lane_rcu_res_c14_s2_credit),
    .lane_rcu_res_c14_s2_stall(lane_rcu_res_c14_s2_stall),
    .lane_rcu_res_c14_s3_valid(lane_rcu_res_c14_s3_valid),
    .lane_rcu_res_c14_s3_payload(lane_rcu_res_c14_s3_payload),
    .lane_rcu_res_c14_s3_credit(lane_rcu_res_c14_s3_credit),
    .lane_rcu_res_c14_s3_stall(lane_rcu_res_c14_s3_stall),
    .lane_rcu_res_c14_wake(lane_rcu_res_c14_wake),
    .lane_rcu_res_c15_s0_valid(lane_rcu_res_c15_s0_valid),
    .lane_rcu_res_c15_s0_payload(lane_rcu_res_c15_s0_payload),
    .lane_rcu_res_c15_s0_credit(lane_rcu_res_c15_s0_credit),
    .lane_rcu_res_c15_s0_stall(lane_rcu_res_c15_s0_stall),
    .lane_rcu_res_c15_s1_valid(lane_rcu_res_c15_s1_valid),
    .lane_rcu_res_c15_s1_payload(lane_rcu_res_c15_s1_payload),
    .lane_rcu_res_c15_s1_credit(lane_rcu_res_c15_s1_credit),
    .lane_rcu_res_c15_s1_stall(lane_rcu_res_c15_s1_stall),
    .lane_rcu_res_c15_s2_valid(lane_rcu_res_c15_s2_valid),
    .lane_rcu_res_c15_s2_payload(lane_rcu_res_c15_s2_payload),
    .lane_rcu_res_c15_s2_credit(lane_rcu_res_c15_s2_credit),
    .lane_rcu_res_c15_s2_stall(lane_rcu_res_c15_s2_stall),
    .lane_rcu_res_c15_s3_valid(lane_rcu_res_c15_s3_valid),
    .lane_rcu_res_c15_s3_payload(lane_rcu_res_c15_s3_payload),
    .lane_rcu_res_c15_s3_credit(lane_rcu_res_c15_s3_credit),
    .lane_rcu_res_c15_s3_stall(lane_rcu_res_c15_s3_stall),
    .lane_rcu_res_c15_wake(lane_rcu_res_c15_wake),
    .lane_rcu_res_c16_s0_valid(lane_rcu_res_c16_s0_valid),
    .lane_rcu_res_c16_s0_payload(lane_rcu_res_c16_s0_payload),
    .lane_rcu_res_c16_s0_credit(lane_rcu_res_c16_s0_credit),
    .lane_rcu_res_c16_s0_stall(lane_rcu_res_c16_s0_stall),
    .lane_rcu_res_c16_s1_valid(lane_rcu_res_c16_s1_valid),
    .lane_rcu_res_c16_s1_payload(lane_rcu_res_c16_s1_payload),
    .lane_rcu_res_c16_s1_credit(lane_rcu_res_c16_s1_credit),
    .lane_rcu_res_c16_s1_stall(lane_rcu_res_c16_s1_stall),
    .lane_rcu_res_c16_s2_valid(lane_rcu_res_c16_s2_valid),
    .lane_rcu_res_c16_s2_payload(lane_rcu_res_c16_s2_payload),
    .lane_rcu_res_c16_s2_credit(lane_rcu_res_c16_s2_credit),
    .lane_rcu_res_c16_s2_stall(lane_rcu_res_c16_s2_stall),
    .lane_rcu_res_c16_s3_valid(lane_rcu_res_c16_s3_valid),
    .lane_rcu_res_c16_s3_payload(lane_rcu_res_c16_s3_payload),
    .lane_rcu_res_c16_s3_credit(lane_rcu_res_c16_s3_credit),
    .lane_rcu_res_c16_s3_stall(lane_rcu_res_c16_s3_stall),
    .lane_rcu_res_c16_wake(lane_rcu_res_c16_wake),
    .lane_rcu_res_c17_s0_valid(lane_rcu_res_c17_s0_valid),
    .lane_rcu_res_c17_s0_payload(lane_rcu_res_c17_s0_payload),
    .lane_rcu_res_c17_s0_credit(lane_rcu_res_c17_s0_credit),
    .lane_rcu_res_c17_s0_stall(lane_rcu_res_c17_s0_stall),
    .lane_rcu_res_c17_s1_valid(lane_rcu_res_c17_s1_valid),
    .lane_rcu_res_c17_s1_payload(lane_rcu_res_c17_s1_payload),
    .lane_rcu_res_c17_s1_credit(lane_rcu_res_c17_s1_credit),
    .lane_rcu_res_c17_s1_stall(lane_rcu_res_c17_s1_stall),
    .lane_rcu_res_c17_s2_valid(lane_rcu_res_c17_s2_valid),
    .lane_rcu_res_c17_s2_payload(lane_rcu_res_c17_s2_payload),
    .lane_rcu_res_c17_s2_credit(lane_rcu_res_c17_s2_credit),
    .lane_rcu_res_c17_s2_stall(lane_rcu_res_c17_s2_stall),
    .lane_rcu_res_c17_s3_valid(lane_rcu_res_c17_s3_valid),
    .lane_rcu_res_c17_s3_payload(lane_rcu_res_c17_s3_payload),
    .lane_rcu_res_c17_s3_credit(lane_rcu_res_c17_s3_credit),
    .lane_rcu_res_c17_s3_stall(lane_rcu_res_c17_s3_stall),
    .lane_rcu_res_c17_wake(lane_rcu_res_c17_wake),
    .lane_rcu_res_c18_s0_valid(lane_rcu_res_c18_s0_valid),
    .lane_rcu_res_c18_s0_payload(lane_rcu_res_c18_s0_payload),
    .lane_rcu_res_c18_s0_credit(lane_rcu_res_c18_s0_credit),
    .lane_rcu_res_c18_s0_stall(lane_rcu_res_c18_s0_stall),
    .lane_rcu_res_c18_s1_valid(lane_rcu_res_c18_s1_valid),
    .lane_rcu_res_c18_s1_payload(lane_rcu_res_c18_s1_payload),
    .lane_rcu_res_c18_s1_credit(lane_rcu_res_c18_s1_credit),
    .lane_rcu_res_c18_s1_stall(lane_rcu_res_c18_s1_stall),
    .lane_rcu_res_c18_s2_valid(lane_rcu_res_c18_s2_valid),
    .lane_rcu_res_c18_s2_payload(lane_rcu_res_c18_s2_payload),
    .lane_rcu_res_c18_s2_credit(lane_rcu_res_c18_s2_credit),
    .lane_rcu_res_c18_s2_stall(lane_rcu_res_c18_s2_stall),
    .lane_rcu_res_c18_s3_valid(lane_rcu_res_c18_s3_valid),
    .lane_rcu_res_c18_s3_payload(lane_rcu_res_c18_s3_payload),
    .lane_rcu_res_c18_s3_credit(lane_rcu_res_c18_s3_credit),
    .lane_rcu_res_c18_s3_stall(lane_rcu_res_c18_s3_stall),
    .lane_rcu_res_c18_wake(lane_rcu_res_c18_wake),
    .lane_rcu_res_c19_s0_valid(lane_rcu_res_c19_s0_valid),
    .lane_rcu_res_c19_s0_payload(lane_rcu_res_c19_s0_payload),
    .lane_rcu_res_c19_s0_credit(lane_rcu_res_c19_s0_credit),
    .lane_rcu_res_c19_s0_stall(lane_rcu_res_c19_s0_stall),
    .lane_rcu_res_c19_s1_valid(lane_rcu_res_c19_s1_valid),
    .lane_rcu_res_c19_s1_payload(lane_rcu_res_c19_s1_payload),
    .lane_rcu_res_c19_s1_credit(lane_rcu_res_c19_s1_credit),
    .lane_rcu_res_c19_s1_stall(lane_rcu_res_c19_s1_stall),
    .lane_rcu_res_c19_s2_valid(lane_rcu_res_c19_s2_valid),
    .lane_rcu_res_c19_s2_payload(lane_rcu_res_c19_s2_payload),
    .lane_rcu_res_c19_s2_credit(lane_rcu_res_c19_s2_credit),
    .lane_rcu_res_c19_s2_stall(lane_rcu_res_c19_s2_stall),
    .lane_rcu_res_c19_s3_valid(lane_rcu_res_c19_s3_valid),
    .lane_rcu_res_c19_s3_payload(lane_rcu_res_c19_s3_payload),
    .lane_rcu_res_c19_s3_credit(lane_rcu_res_c19_s3_credit),
    .lane_rcu_res_c19_s3_stall(lane_rcu_res_c19_s3_stall),
    .lane_rcu_res_c19_wake(lane_rcu_res_c19_wake),
    .lane_rcu_res_c20_s0_valid(lane_rcu_res_c20_s0_valid),
    .lane_rcu_res_c20_s0_payload(lane_rcu_res_c20_s0_payload),
    .lane_rcu_res_c20_s0_credit(lane_rcu_res_c20_s0_credit),
    .lane_rcu_res_c20_s0_stall(lane_rcu_res_c20_s0_stall),
    .lane_rcu_res_c20_s1_valid(lane_rcu_res_c20_s1_valid),
    .lane_rcu_res_c20_s1_payload(lane_rcu_res_c20_s1_payload),
    .lane_rcu_res_c20_s1_credit(lane_rcu_res_c20_s1_credit),
    .lane_rcu_res_c20_s1_stall(lane_rcu_res_c20_s1_stall),
    .lane_rcu_res_c20_s2_valid(lane_rcu_res_c20_s2_valid),
    .lane_rcu_res_c20_s2_payload(lane_rcu_res_c20_s2_payload),
    .lane_rcu_res_c20_s2_credit(lane_rcu_res_c20_s2_credit),
    .lane_rcu_res_c20_s2_stall(lane_rcu_res_c20_s2_stall),
    .lane_rcu_res_c20_s3_valid(lane_rcu_res_c20_s3_valid),
    .lane_rcu_res_c20_s3_payload(lane_rcu_res_c20_s3_payload),
    .lane_rcu_res_c20_s3_credit(lane_rcu_res_c20_s3_credit),
    .lane_rcu_res_c20_s3_stall(lane_rcu_res_c20_s3_stall),
    .lane_rcu_res_c20_wake(lane_rcu_res_c20_wake),
    .lane_rcu_res_c21_s0_valid(lane_rcu_res_c21_s0_valid),
    .lane_rcu_res_c21_s0_payload(lane_rcu_res_c21_s0_payload),
    .lane_rcu_res_c21_s0_credit(lane_rcu_res_c21_s0_credit),
    .lane_rcu_res_c21_s0_stall(lane_rcu_res_c21_s0_stall),
    .lane_rcu_res_c21_s1_valid(lane_rcu_res_c21_s1_valid),
    .lane_rcu_res_c21_s1_payload(lane_rcu_res_c21_s1_payload),
    .lane_rcu_res_c21_s1_credit(lane_rcu_res_c21_s1_credit),
    .lane_rcu_res_c21_s1_stall(lane_rcu_res_c21_s1_stall),
    .lane_rcu_res_c21_s2_valid(lane_rcu_res_c21_s2_valid),
    .lane_rcu_res_c21_s2_payload(lane_rcu_res_c21_s2_payload),
    .lane_rcu_res_c21_s2_credit(lane_rcu_res_c21_s2_credit),
    .lane_rcu_res_c21_s2_stall(lane_rcu_res_c21_s2_stall),
    .lane_rcu_res_c21_s3_valid(lane_rcu_res_c21_s3_valid),
    .lane_rcu_res_c21_s3_payload(lane_rcu_res_c21_s3_payload),
    .lane_rcu_res_c21_s3_credit(lane_rcu_res_c21_s3_credit),
    .lane_rcu_res_c21_s3_stall(lane_rcu_res_c21_s3_stall),
    .lane_rcu_res_c21_wake(lane_rcu_res_c21_wake),
    .lane_rcu_res_c22_s0_valid(lane_rcu_res_c22_s0_valid),
    .lane_rcu_res_c22_s0_payload(lane_rcu_res_c22_s0_payload),
    .lane_rcu_res_c22_s0_credit(lane_rcu_res_c22_s0_credit),
    .lane_rcu_res_c22_s0_stall(lane_rcu_res_c22_s0_stall),
    .lane_rcu_res_c22_s1_valid(lane_rcu_res_c22_s1_valid),
    .lane_rcu_res_c22_s1_payload(lane_rcu_res_c22_s1_payload),
    .lane_rcu_res_c22_s1_credit(lane_rcu_res_c22_s1_credit),
    .lane_rcu_res_c22_s1_stall(lane_rcu_res_c22_s1_stall),
    .lane_rcu_res_c22_s2_valid(lane_rcu_res_c22_s2_valid),
    .lane_rcu_res_c22_s2_payload(lane_rcu_res_c22_s2_payload),
    .lane_rcu_res_c22_s2_credit(lane_rcu_res_c22_s2_credit),
    .lane_rcu_res_c22_s2_stall(lane_rcu_res_c22_s2_stall),
    .lane_rcu_res_c22_s3_valid(lane_rcu_res_c22_s3_valid),
    .lane_rcu_res_c22_s3_payload(lane_rcu_res_c22_s3_payload),
    .lane_rcu_res_c22_s3_credit(lane_rcu_res_c22_s3_credit),
    .lane_rcu_res_c22_s3_stall(lane_rcu_res_c22_s3_stall),
    .lane_rcu_res_c22_wake(lane_rcu_res_c22_wake),
    .lane_rcu_res_c23_s0_valid(lane_rcu_res_c23_s0_valid),
    .lane_rcu_res_c23_s0_payload(lane_rcu_res_c23_s0_payload),
    .lane_rcu_res_c23_s0_credit(lane_rcu_res_c23_s0_credit),
    .lane_rcu_res_c23_s0_stall(lane_rcu_res_c23_s0_stall),
    .lane_rcu_res_c23_s1_valid(lane_rcu_res_c23_s1_valid),
    .lane_rcu_res_c23_s1_payload(lane_rcu_res_c23_s1_payload),
    .lane_rcu_res_c23_s1_credit(lane_rcu_res_c23_s1_credit),
    .lane_rcu_res_c23_s1_stall(lane_rcu_res_c23_s1_stall),
    .lane_rcu_res_c23_s2_valid(lane_rcu_res_c23_s2_valid),
    .lane_rcu_res_c23_s2_payload(lane_rcu_res_c23_s2_payload),
    .lane_rcu_res_c23_s2_credit(lane_rcu_res_c23_s2_credit),
    .lane_rcu_res_c23_s2_stall(lane_rcu_res_c23_s2_stall),
    .lane_rcu_res_c23_s3_valid(lane_rcu_res_c23_s3_valid),
    .lane_rcu_res_c23_s3_payload(lane_rcu_res_c23_s3_payload),
    .lane_rcu_res_c23_s3_credit(lane_rcu_res_c23_s3_credit),
    .lane_rcu_res_c23_s3_stall(lane_rcu_res_c23_s3_stall),
    .lane_rcu_res_c23_wake(lane_rcu_res_c23_wake),
    .lane_rcu_res_c24_s0_valid(lane_rcu_res_c24_s0_valid),
    .lane_rcu_res_c24_s0_payload(lane_rcu_res_c24_s0_payload),
    .lane_rcu_res_c24_s0_credit(lane_rcu_res_c24_s0_credit),
    .lane_rcu_res_c24_s0_stall(lane_rcu_res_c24_s0_stall),
    .lane_rcu_res_c24_s1_valid(lane_rcu_res_c24_s1_valid),
    .lane_rcu_res_c24_s1_payload(lane_rcu_res_c24_s1_payload),
    .lane_rcu_res_c24_s1_credit(lane_rcu_res_c24_s1_credit),
    .lane_rcu_res_c24_s1_stall(lane_rcu_res_c24_s1_stall),
    .lane_rcu_res_c24_s2_valid(lane_rcu_res_c24_s2_valid),
    .lane_rcu_res_c24_s2_payload(lane_rcu_res_c24_s2_payload),
    .lane_rcu_res_c24_s2_credit(lane_rcu_res_c24_s2_credit),
    .lane_rcu_res_c24_s2_stall(lane_rcu_res_c24_s2_stall),
    .lane_rcu_res_c24_s3_valid(lane_rcu_res_c24_s3_valid),
    .lane_rcu_res_c24_s3_payload(lane_rcu_res_c24_s3_payload),
    .lane_rcu_res_c24_s3_credit(lane_rcu_res_c24_s3_credit),
    .lane_rcu_res_c24_s3_stall(lane_rcu_res_c24_s3_stall),
    .lane_rcu_res_c24_wake(lane_rcu_res_c24_wake),
    .lane_rcu_res_c25_s0_valid(lane_rcu_res_c25_s0_valid),
    .lane_rcu_res_c25_s0_payload(lane_rcu_res_c25_s0_payload),
    .lane_rcu_res_c25_s0_credit(lane_rcu_res_c25_s0_credit),
    .lane_rcu_res_c25_s0_stall(lane_rcu_res_c25_s0_stall),
    .lane_rcu_res_c25_s1_valid(lane_rcu_res_c25_s1_valid),
    .lane_rcu_res_c25_s1_payload(lane_rcu_res_c25_s1_payload),
    .lane_rcu_res_c25_s1_credit(lane_rcu_res_c25_s1_credit),
    .lane_rcu_res_c25_s1_stall(lane_rcu_res_c25_s1_stall),
    .lane_rcu_res_c25_s2_valid(lane_rcu_res_c25_s2_valid),
    .lane_rcu_res_c25_s2_payload(lane_rcu_res_c25_s2_payload),
    .lane_rcu_res_c25_s2_credit(lane_rcu_res_c25_s2_credit),
    .lane_rcu_res_c25_s2_stall(lane_rcu_res_c25_s2_stall),
    .lane_rcu_res_c25_s3_valid(lane_rcu_res_c25_s3_valid),
    .lane_rcu_res_c25_s3_payload(lane_rcu_res_c25_s3_payload),
    .lane_rcu_res_c25_s3_credit(lane_rcu_res_c25_s3_credit),
    .lane_rcu_res_c25_s3_stall(lane_rcu_res_c25_s3_stall),
    .lane_rcu_res_c25_wake(lane_rcu_res_c25_wake),
    .lane_rcu_res_c26_s0_valid(lane_rcu_res_c26_s0_valid),
    .lane_rcu_res_c26_s0_payload(lane_rcu_res_c26_s0_payload),
    .lane_rcu_res_c26_s0_credit(lane_rcu_res_c26_s0_credit),
    .lane_rcu_res_c26_s0_stall(lane_rcu_res_c26_s0_stall),
    .lane_rcu_res_c26_s1_valid(lane_rcu_res_c26_s1_valid),
    .lane_rcu_res_c26_s1_payload(lane_rcu_res_c26_s1_payload),
    .lane_rcu_res_c26_s1_credit(lane_rcu_res_c26_s1_credit),
    .lane_rcu_res_c26_s1_stall(lane_rcu_res_c26_s1_stall),
    .lane_rcu_res_c26_s2_valid(lane_rcu_res_c26_s2_valid),
    .lane_rcu_res_c26_s2_payload(lane_rcu_res_c26_s2_payload),
    .lane_rcu_res_c26_s2_credit(lane_rcu_res_c26_s2_credit),
    .lane_rcu_res_c26_s2_stall(lane_rcu_res_c26_s2_stall),
    .lane_rcu_res_c26_s3_valid(lane_rcu_res_c26_s3_valid),
    .lane_rcu_res_c26_s3_payload(lane_rcu_res_c26_s3_payload),
    .lane_rcu_res_c26_s3_credit(lane_rcu_res_c26_s3_credit),
    .lane_rcu_res_c26_s3_stall(lane_rcu_res_c26_s3_stall),
    .lane_rcu_res_c26_wake(lane_rcu_res_c26_wake),
    .lane_rcu_res_c27_s0_valid(lane_rcu_res_c27_s0_valid),
    .lane_rcu_res_c27_s0_payload(lane_rcu_res_c27_s0_payload),
    .lane_rcu_res_c27_s0_credit(lane_rcu_res_c27_s0_credit),
    .lane_rcu_res_c27_s0_stall(lane_rcu_res_c27_s0_stall),
    .lane_rcu_res_c27_s1_valid(lane_rcu_res_c27_s1_valid),
    .lane_rcu_res_c27_s1_payload(lane_rcu_res_c27_s1_payload),
    .lane_rcu_res_c27_s1_credit(lane_rcu_res_c27_s1_credit),
    .lane_rcu_res_c27_s1_stall(lane_rcu_res_c27_s1_stall),
    .lane_rcu_res_c27_s2_valid(lane_rcu_res_c27_s2_valid),
    .lane_rcu_res_c27_s2_payload(lane_rcu_res_c27_s2_payload),
    .lane_rcu_res_c27_s2_credit(lane_rcu_res_c27_s2_credit),
    .lane_rcu_res_c27_s2_stall(lane_rcu_res_c27_s2_stall),
    .lane_rcu_res_c27_s3_valid(lane_rcu_res_c27_s3_valid),
    .lane_rcu_res_c27_s3_payload(lane_rcu_res_c27_s3_payload),
    .lane_rcu_res_c27_s3_credit(lane_rcu_res_c27_s3_credit),
    .lane_rcu_res_c27_s3_stall(lane_rcu_res_c27_s3_stall),
    .lane_rcu_res_c27_wake(lane_rcu_res_c27_wake),
    .lane_rcu_res_c28_s0_valid(lane_rcu_res_c28_s0_valid),
    .lane_rcu_res_c28_s0_payload(lane_rcu_res_c28_s0_payload),
    .lane_rcu_res_c28_s0_credit(lane_rcu_res_c28_s0_credit),
    .lane_rcu_res_c28_s0_stall(lane_rcu_res_c28_s0_stall),
    .lane_rcu_res_c28_s1_valid(lane_rcu_res_c28_s1_valid),
    .lane_rcu_res_c28_s1_payload(lane_rcu_res_c28_s1_payload),
    .lane_rcu_res_c28_s1_credit(lane_rcu_res_c28_s1_credit),
    .lane_rcu_res_c28_s1_stall(lane_rcu_res_c28_s1_stall),
    .lane_rcu_res_c28_s2_valid(lane_rcu_res_c28_s2_valid),
    .lane_rcu_res_c28_s2_payload(lane_rcu_res_c28_s2_payload),
    .lane_rcu_res_c28_s2_credit(lane_rcu_res_c28_s2_credit),
    .lane_rcu_res_c28_s2_stall(lane_rcu_res_c28_s2_stall),
    .lane_rcu_res_c28_s3_valid(lane_rcu_res_c28_s3_valid),
    .lane_rcu_res_c28_s3_payload(lane_rcu_res_c28_s3_payload),
    .lane_rcu_res_c28_s3_credit(lane_rcu_res_c28_s3_credit),
    .lane_rcu_res_c28_s3_stall(lane_rcu_res_c28_s3_stall),
    .lane_rcu_res_c28_wake(lane_rcu_res_c28_wake),
    .lane_rcu_res_c29_s0_valid(lane_rcu_res_c29_s0_valid),
    .lane_rcu_res_c29_s0_payload(lane_rcu_res_c29_s0_payload),
    .lane_rcu_res_c29_s0_credit(lane_rcu_res_c29_s0_credit),
    .lane_rcu_res_c29_s0_stall(lane_rcu_res_c29_s0_stall),
    .lane_rcu_res_c29_s1_valid(lane_rcu_res_c29_s1_valid),
    .lane_rcu_res_c29_s1_payload(lane_rcu_res_c29_s1_payload),
    .lane_rcu_res_c29_s1_credit(lane_rcu_res_c29_s1_credit),
    .lane_rcu_res_c29_s1_stall(lane_rcu_res_c29_s1_stall),
    .lane_rcu_res_c29_s2_valid(lane_rcu_res_c29_s2_valid),
    .lane_rcu_res_c29_s2_payload(lane_rcu_res_c29_s2_payload),
    .lane_rcu_res_c29_s2_credit(lane_rcu_res_c29_s2_credit),
    .lane_rcu_res_c29_s2_stall(lane_rcu_res_c29_s2_stall),
    .lane_rcu_res_c29_s3_valid(lane_rcu_res_c29_s3_valid),
    .lane_rcu_res_c29_s3_payload(lane_rcu_res_c29_s3_payload),
    .lane_rcu_res_c29_s3_credit(lane_rcu_res_c29_s3_credit),
    .lane_rcu_res_c29_s3_stall(lane_rcu_res_c29_s3_stall),
    .lane_rcu_res_c29_wake(lane_rcu_res_c29_wake),
    .lane_rcu_res_c30_s0_valid(lane_rcu_res_c30_s0_valid),
    .lane_rcu_res_c30_s0_payload(lane_rcu_res_c30_s0_payload),
    .lane_rcu_res_c30_s0_credit(lane_rcu_res_c30_s0_credit),
    .lane_rcu_res_c30_s0_stall(lane_rcu_res_c30_s0_stall),
    .lane_rcu_res_c30_s1_valid(lane_rcu_res_c30_s1_valid),
    .lane_rcu_res_c30_s1_payload(lane_rcu_res_c30_s1_payload),
    .lane_rcu_res_c30_s1_credit(lane_rcu_res_c30_s1_credit),
    .lane_rcu_res_c30_s1_stall(lane_rcu_res_c30_s1_stall),
    .lane_rcu_res_c30_s2_valid(lane_rcu_res_c30_s2_valid),
    .lane_rcu_res_c30_s2_payload(lane_rcu_res_c30_s2_payload),
    .lane_rcu_res_c30_s2_credit(lane_rcu_res_c30_s2_credit),
    .lane_rcu_res_c30_s2_stall(lane_rcu_res_c30_s2_stall),
    .lane_rcu_res_c30_s3_valid(lane_rcu_res_c30_s3_valid),
    .lane_rcu_res_c30_s3_payload(lane_rcu_res_c30_s3_payload),
    .lane_rcu_res_c30_s3_credit(lane_rcu_res_c30_s3_credit),
    .lane_rcu_res_c30_s3_stall(lane_rcu_res_c30_s3_stall),
    .lane_rcu_res_c30_wake(lane_rcu_res_c30_wake),
    .lane_rcu_res_c31_s0_valid(lane_rcu_res_c31_s0_valid),
    .lane_rcu_res_c31_s0_payload(lane_rcu_res_c31_s0_payload),
    .lane_rcu_res_c31_s0_credit(lane_rcu_res_c31_s0_credit),
    .lane_rcu_res_c31_s0_stall(lane_rcu_res_c31_s0_stall),
    .lane_rcu_res_c31_s1_valid(lane_rcu_res_c31_s1_valid),
    .lane_rcu_res_c31_s1_payload(lane_rcu_res_c31_s1_payload),
    .lane_rcu_res_c31_s1_credit(lane_rcu_res_c31_s1_credit),
    .lane_rcu_res_c31_s1_stall(lane_rcu_res_c31_s1_stall),
    .lane_rcu_res_c31_s2_valid(lane_rcu_res_c31_s2_valid),
    .lane_rcu_res_c31_s2_payload(lane_rcu_res_c31_s2_payload),
    .lane_rcu_res_c31_s2_credit(lane_rcu_res_c31_s2_credit),
    .lane_rcu_res_c31_s2_stall(lane_rcu_res_c31_s2_stall),
    .lane_rcu_res_c31_s3_valid(lane_rcu_res_c31_s3_valid),
    .lane_rcu_res_c31_s3_payload(lane_rcu_res_c31_s3_payload),
    .lane_rcu_res_c31_s3_credit(lane_rcu_res_c31_s3_credit),
    .lane_rcu_res_c31_s3_stall(lane_rcu_res_c31_s3_stall),
    .lane_rcu_res_c31_wake(lane_rcu_res_c31_wake),
    .rcu_ooe_done_s0_valid(rcu_ooe_done_s0_valid),
    .rcu_ooe_done_s0_payload(rcu_ooe_done_s0_payload),
    .rcu_ooe_done_s0_credit(rcu_ooe_done_s0_credit),
    .rcu_ooe_done_s0_stall(rcu_ooe_done_s0_stall),
    .rcu_ooe_done_s1_valid(rcu_ooe_done_s1_valid),
    .rcu_ooe_done_s1_payload(rcu_ooe_done_s1_payload),
    .rcu_ooe_done_s1_credit(rcu_ooe_done_s1_credit),
    .rcu_ooe_done_s1_stall(rcu_ooe_done_s1_stall),
    .rcu_ooe_done_s2_valid(rcu_ooe_done_s2_valid),
    .rcu_ooe_done_s2_payload(rcu_ooe_done_s2_payload),
    .rcu_ooe_done_s2_credit(rcu_ooe_done_s2_credit),
    .rcu_ooe_done_s2_stall(rcu_ooe_done_s2_stall),
    .rcu_ooe_done_s3_valid(rcu_ooe_done_s3_valid),
    .rcu_ooe_done_s3_payload(rcu_ooe_done_s3_payload),
    .rcu_ooe_done_s3_credit(rcu_ooe_done_s3_credit),
    .rcu_ooe_done_s3_stall(rcu_ooe_done_s3_stall),
    .rcu_ooe_done_wake(rcu_ooe_done_wake),
    .rcu_miu_addr_s0_valid(rcu_miu_addr_s0_valid),
    .rcu_miu_addr_s0_payload(rcu_miu_addr_s0_payload),
    .rcu_miu_addr_s0_credit(rcu_miu_addr_s0_credit),
    .rcu_miu_addr_s0_stall(rcu_miu_addr_s0_stall),
    .rcu_miu_addr_s1_valid(rcu_miu_addr_s1_valid),
    .rcu_miu_addr_s1_payload(rcu_miu_addr_s1_payload),
    .rcu_miu_addr_s1_credit(rcu_miu_addr_s1_credit),
    .rcu_miu_addr_s1_stall(rcu_miu_addr_s1_stall),
    .rcu_miu_addr_s2_valid(rcu_miu_addr_s2_valid),
    .rcu_miu_addr_s2_payload(rcu_miu_addr_s2_payload),
    .rcu_miu_addr_s2_credit(rcu_miu_addr_s2_credit),
    .rcu_miu_addr_s2_stall(rcu_miu_addr_s2_stall),
    .rcu_miu_addr_s3_valid(rcu_miu_addr_s3_valid),
    .rcu_miu_addr_s3_payload(rcu_miu_addr_s3_payload),
    .rcu_miu_addr_s3_credit(rcu_miu_addr_s3_credit),
    .rcu_miu_addr_s3_stall(rcu_miu_addr_s3_stall),
    .rcu_miu_addr_wake(rcu_miu_addr_wake),
    .miu_rcu_data_s0_valid(miu_rcu_data_s0_valid),
    .miu_rcu_data_s0_payload(miu_rcu_data_s0_payload),
    .miu_rcu_data_s0_credit(miu_rcu_data_s0_credit),
    .miu_rcu_data_s0_stall(miu_rcu_data_s0_stall),
    .miu_rcu_data_s1_valid(miu_rcu_data_s1_valid),
    .miu_rcu_data_s1_payload(miu_rcu_data_s1_payload),
    .miu_rcu_data_s1_credit(miu_rcu_data_s1_credit),
    .miu_rcu_data_s1_stall(miu_rcu_data_s1_stall),
    .miu_rcu_data_s2_valid(miu_rcu_data_s2_valid),
    .miu_rcu_data_s2_payload(miu_rcu_data_s2_payload),
    .miu_rcu_data_s2_credit(miu_rcu_data_s2_credit),
    .miu_rcu_data_s2_stall(miu_rcu_data_s2_stall),
    .miu_rcu_data_s3_valid(miu_rcu_data_s3_valid),
    .miu_rcu_data_s3_payload(miu_rcu_data_s3_payload),
    .miu_rcu_data_s3_credit(miu_rcu_data_s3_credit),
    .miu_rcu_data_s3_stall(miu_rcu_data_s3_stall),
    .miu_rcu_data_wake(miu_rcu_data_wake),
    .rau_rcu_mig_valid(rau_rcu_mig_valid),
    .rau_rcu_mig_payload(rau_rcu_mig_payload),
    .rau_rcu_mig_credit(rau_rcu_mig_credit),
    .rau_rcu_mig_stall(rau_rcu_mig_stall),
    .rau_rcu_mig_wake(rau_rcu_mig_wake),
    .rcu_pca_mig_valid(rcu_pca_mig_valid),
    .rcu_pca_mig_payload(rcu_pca_mig_payload),
    .rcu_pca_mig_credit(rcu_pca_mig_credit),
    .rcu_pca_mig_stall(rcu_pca_mig_stall),
    .rcu_pca_mig_wake(rcu_pca_mig_wake),
    .pca_rcu_mig_valid(pca_rcu_mig_valid),
    .pca_rcu_mig_payload(pca_rcu_mig_payload),
    .pca_rcu_mig_credit(pca_rcu_mig_credit),
    .pca_rcu_mig_stall(pca_rcu_mig_stall),
    .pca_rcu_mig_wake(pca_rcu_mig_wake)
`ifdef CCV_TRACE
    , .ooe_rcu_issue_s0_tid(ooe_rcu_issue_s0_tid),
      .ooe_rcu_issue_s1_tid(ooe_rcu_issue_s1_tid),
      .ooe_rcu_issue_s2_tid(ooe_rcu_issue_s2_tid),
      .ooe_rcu_issue_s3_tid(ooe_rcu_issue_s3_tid),
      .rcu_lane_ops_c00_s0_tid(rcu_lane_ops_c00_s0_tid),
      .rcu_lane_ops_c00_s1_tid(rcu_lane_ops_c00_s1_tid),
      .rcu_lane_ops_c00_s2_tid(rcu_lane_ops_c00_s2_tid),
      .rcu_lane_ops_c00_s3_tid(rcu_lane_ops_c00_s3_tid),
      .rcu_lane_ops_c01_s0_tid(rcu_lane_ops_c01_s0_tid),
      .rcu_lane_ops_c01_s1_tid(rcu_lane_ops_c01_s1_tid),
      .rcu_lane_ops_c01_s2_tid(rcu_lane_ops_c01_s2_tid),
      .rcu_lane_ops_c01_s3_tid(rcu_lane_ops_c01_s3_tid),
      .rcu_lane_ops_c02_s0_tid(rcu_lane_ops_c02_s0_tid),
      .rcu_lane_ops_c02_s1_tid(rcu_lane_ops_c02_s1_tid),
      .rcu_lane_ops_c02_s2_tid(rcu_lane_ops_c02_s2_tid),
      .rcu_lane_ops_c02_s3_tid(rcu_lane_ops_c02_s3_tid),
      .rcu_lane_ops_c03_s0_tid(rcu_lane_ops_c03_s0_tid),
      .rcu_lane_ops_c03_s1_tid(rcu_lane_ops_c03_s1_tid),
      .rcu_lane_ops_c03_s2_tid(rcu_lane_ops_c03_s2_tid),
      .rcu_lane_ops_c03_s3_tid(rcu_lane_ops_c03_s3_tid),
      .rcu_lane_ops_c04_s0_tid(rcu_lane_ops_c04_s0_tid),
      .rcu_lane_ops_c04_s1_tid(rcu_lane_ops_c04_s1_tid),
      .rcu_lane_ops_c04_s2_tid(rcu_lane_ops_c04_s2_tid),
      .rcu_lane_ops_c04_s3_tid(rcu_lane_ops_c04_s3_tid),
      .rcu_lane_ops_c05_s0_tid(rcu_lane_ops_c05_s0_tid),
      .rcu_lane_ops_c05_s1_tid(rcu_lane_ops_c05_s1_tid),
      .rcu_lane_ops_c05_s2_tid(rcu_lane_ops_c05_s2_tid),
      .rcu_lane_ops_c05_s3_tid(rcu_lane_ops_c05_s3_tid),
      .rcu_lane_ops_c06_s0_tid(rcu_lane_ops_c06_s0_tid),
      .rcu_lane_ops_c06_s1_tid(rcu_lane_ops_c06_s1_tid),
      .rcu_lane_ops_c06_s2_tid(rcu_lane_ops_c06_s2_tid),
      .rcu_lane_ops_c06_s3_tid(rcu_lane_ops_c06_s3_tid),
      .rcu_lane_ops_c07_s0_tid(rcu_lane_ops_c07_s0_tid),
      .rcu_lane_ops_c07_s1_tid(rcu_lane_ops_c07_s1_tid),
      .rcu_lane_ops_c07_s2_tid(rcu_lane_ops_c07_s2_tid),
      .rcu_lane_ops_c07_s3_tid(rcu_lane_ops_c07_s3_tid),
      .rcu_lane_ops_c08_s0_tid(rcu_lane_ops_c08_s0_tid),
      .rcu_lane_ops_c08_s1_tid(rcu_lane_ops_c08_s1_tid),
      .rcu_lane_ops_c08_s2_tid(rcu_lane_ops_c08_s2_tid),
      .rcu_lane_ops_c08_s3_tid(rcu_lane_ops_c08_s3_tid),
      .rcu_lane_ops_c09_s0_tid(rcu_lane_ops_c09_s0_tid),
      .rcu_lane_ops_c09_s1_tid(rcu_lane_ops_c09_s1_tid),
      .rcu_lane_ops_c09_s2_tid(rcu_lane_ops_c09_s2_tid),
      .rcu_lane_ops_c09_s3_tid(rcu_lane_ops_c09_s3_tid),
      .rcu_lane_ops_c10_s0_tid(rcu_lane_ops_c10_s0_tid),
      .rcu_lane_ops_c10_s1_tid(rcu_lane_ops_c10_s1_tid),
      .rcu_lane_ops_c10_s2_tid(rcu_lane_ops_c10_s2_tid),
      .rcu_lane_ops_c10_s3_tid(rcu_lane_ops_c10_s3_tid),
      .rcu_lane_ops_c11_s0_tid(rcu_lane_ops_c11_s0_tid),
      .rcu_lane_ops_c11_s1_tid(rcu_lane_ops_c11_s1_tid),
      .rcu_lane_ops_c11_s2_tid(rcu_lane_ops_c11_s2_tid),
      .rcu_lane_ops_c11_s3_tid(rcu_lane_ops_c11_s3_tid),
      .rcu_lane_ops_c12_s0_tid(rcu_lane_ops_c12_s0_tid),
      .rcu_lane_ops_c12_s1_tid(rcu_lane_ops_c12_s1_tid),
      .rcu_lane_ops_c12_s2_tid(rcu_lane_ops_c12_s2_tid),
      .rcu_lane_ops_c12_s3_tid(rcu_lane_ops_c12_s3_tid),
      .rcu_lane_ops_c13_s0_tid(rcu_lane_ops_c13_s0_tid),
      .rcu_lane_ops_c13_s1_tid(rcu_lane_ops_c13_s1_tid),
      .rcu_lane_ops_c13_s2_tid(rcu_lane_ops_c13_s2_tid),
      .rcu_lane_ops_c13_s3_tid(rcu_lane_ops_c13_s3_tid),
      .rcu_lane_ops_c14_s0_tid(rcu_lane_ops_c14_s0_tid),
      .rcu_lane_ops_c14_s1_tid(rcu_lane_ops_c14_s1_tid),
      .rcu_lane_ops_c14_s2_tid(rcu_lane_ops_c14_s2_tid),
      .rcu_lane_ops_c14_s3_tid(rcu_lane_ops_c14_s3_tid),
      .rcu_lane_ops_c15_s0_tid(rcu_lane_ops_c15_s0_tid),
      .rcu_lane_ops_c15_s1_tid(rcu_lane_ops_c15_s1_tid),
      .rcu_lane_ops_c15_s2_tid(rcu_lane_ops_c15_s2_tid),
      .rcu_lane_ops_c15_s3_tid(rcu_lane_ops_c15_s3_tid),
      .rcu_lane_ops_c16_s0_tid(rcu_lane_ops_c16_s0_tid),
      .rcu_lane_ops_c16_s1_tid(rcu_lane_ops_c16_s1_tid),
      .rcu_lane_ops_c16_s2_tid(rcu_lane_ops_c16_s2_tid),
      .rcu_lane_ops_c16_s3_tid(rcu_lane_ops_c16_s3_tid),
      .rcu_lane_ops_c17_s0_tid(rcu_lane_ops_c17_s0_tid),
      .rcu_lane_ops_c17_s1_tid(rcu_lane_ops_c17_s1_tid),
      .rcu_lane_ops_c17_s2_tid(rcu_lane_ops_c17_s2_tid),
      .rcu_lane_ops_c17_s3_tid(rcu_lane_ops_c17_s3_tid),
      .rcu_lane_ops_c18_s0_tid(rcu_lane_ops_c18_s0_tid),
      .rcu_lane_ops_c18_s1_tid(rcu_lane_ops_c18_s1_tid),
      .rcu_lane_ops_c18_s2_tid(rcu_lane_ops_c18_s2_tid),
      .rcu_lane_ops_c18_s3_tid(rcu_lane_ops_c18_s3_tid),
      .rcu_lane_ops_c19_s0_tid(rcu_lane_ops_c19_s0_tid),
      .rcu_lane_ops_c19_s1_tid(rcu_lane_ops_c19_s1_tid),
      .rcu_lane_ops_c19_s2_tid(rcu_lane_ops_c19_s2_tid),
      .rcu_lane_ops_c19_s3_tid(rcu_lane_ops_c19_s3_tid),
      .rcu_lane_ops_c20_s0_tid(rcu_lane_ops_c20_s0_tid),
      .rcu_lane_ops_c20_s1_tid(rcu_lane_ops_c20_s1_tid),
      .rcu_lane_ops_c20_s2_tid(rcu_lane_ops_c20_s2_tid),
      .rcu_lane_ops_c20_s3_tid(rcu_lane_ops_c20_s3_tid),
      .rcu_lane_ops_c21_s0_tid(rcu_lane_ops_c21_s0_tid),
      .rcu_lane_ops_c21_s1_tid(rcu_lane_ops_c21_s1_tid),
      .rcu_lane_ops_c21_s2_tid(rcu_lane_ops_c21_s2_tid),
      .rcu_lane_ops_c21_s3_tid(rcu_lane_ops_c21_s3_tid),
      .rcu_lane_ops_c22_s0_tid(rcu_lane_ops_c22_s0_tid),
      .rcu_lane_ops_c22_s1_tid(rcu_lane_ops_c22_s1_tid),
      .rcu_lane_ops_c22_s2_tid(rcu_lane_ops_c22_s2_tid),
      .rcu_lane_ops_c22_s3_tid(rcu_lane_ops_c22_s3_tid),
      .rcu_lane_ops_c23_s0_tid(rcu_lane_ops_c23_s0_tid),
      .rcu_lane_ops_c23_s1_tid(rcu_lane_ops_c23_s1_tid),
      .rcu_lane_ops_c23_s2_tid(rcu_lane_ops_c23_s2_tid),
      .rcu_lane_ops_c23_s3_tid(rcu_lane_ops_c23_s3_tid),
      .rcu_lane_ops_c24_s0_tid(rcu_lane_ops_c24_s0_tid),
      .rcu_lane_ops_c24_s1_tid(rcu_lane_ops_c24_s1_tid),
      .rcu_lane_ops_c24_s2_tid(rcu_lane_ops_c24_s2_tid),
      .rcu_lane_ops_c24_s3_tid(rcu_lane_ops_c24_s3_tid),
      .rcu_lane_ops_c25_s0_tid(rcu_lane_ops_c25_s0_tid),
      .rcu_lane_ops_c25_s1_tid(rcu_lane_ops_c25_s1_tid),
      .rcu_lane_ops_c25_s2_tid(rcu_lane_ops_c25_s2_tid),
      .rcu_lane_ops_c25_s3_tid(rcu_lane_ops_c25_s3_tid),
      .rcu_lane_ops_c26_s0_tid(rcu_lane_ops_c26_s0_tid),
      .rcu_lane_ops_c26_s1_tid(rcu_lane_ops_c26_s1_tid),
      .rcu_lane_ops_c26_s2_tid(rcu_lane_ops_c26_s2_tid),
      .rcu_lane_ops_c26_s3_tid(rcu_lane_ops_c26_s3_tid),
      .rcu_lane_ops_c27_s0_tid(rcu_lane_ops_c27_s0_tid),
      .rcu_lane_ops_c27_s1_tid(rcu_lane_ops_c27_s1_tid),
      .rcu_lane_ops_c27_s2_tid(rcu_lane_ops_c27_s2_tid),
      .rcu_lane_ops_c27_s3_tid(rcu_lane_ops_c27_s3_tid),
      .rcu_lane_ops_c28_s0_tid(rcu_lane_ops_c28_s0_tid),
      .rcu_lane_ops_c28_s1_tid(rcu_lane_ops_c28_s1_tid),
      .rcu_lane_ops_c28_s2_tid(rcu_lane_ops_c28_s2_tid),
      .rcu_lane_ops_c28_s3_tid(rcu_lane_ops_c28_s3_tid),
      .rcu_lane_ops_c29_s0_tid(rcu_lane_ops_c29_s0_tid),
      .rcu_lane_ops_c29_s1_tid(rcu_lane_ops_c29_s1_tid),
      .rcu_lane_ops_c29_s2_tid(rcu_lane_ops_c29_s2_tid),
      .rcu_lane_ops_c29_s3_tid(rcu_lane_ops_c29_s3_tid),
      .rcu_lane_ops_c30_s0_tid(rcu_lane_ops_c30_s0_tid),
      .rcu_lane_ops_c30_s1_tid(rcu_lane_ops_c30_s1_tid),
      .rcu_lane_ops_c30_s2_tid(rcu_lane_ops_c30_s2_tid),
      .rcu_lane_ops_c30_s3_tid(rcu_lane_ops_c30_s3_tid),
      .rcu_lane_ops_c31_s0_tid(rcu_lane_ops_c31_s0_tid),
      .rcu_lane_ops_c31_s1_tid(rcu_lane_ops_c31_s1_tid),
      .rcu_lane_ops_c31_s2_tid(rcu_lane_ops_c31_s2_tid),
      .rcu_lane_ops_c31_s3_tid(rcu_lane_ops_c31_s3_tid),
      .lane_rcu_res_c00_s0_tid(lane_rcu_res_c00_s0_tid),
      .lane_rcu_res_c00_s1_tid(lane_rcu_res_c00_s1_tid),
      .lane_rcu_res_c00_s2_tid(lane_rcu_res_c00_s2_tid),
      .lane_rcu_res_c00_s3_tid(lane_rcu_res_c00_s3_tid),
      .lane_rcu_res_c01_s0_tid(lane_rcu_res_c01_s0_tid),
      .lane_rcu_res_c01_s1_tid(lane_rcu_res_c01_s1_tid),
      .lane_rcu_res_c01_s2_tid(lane_rcu_res_c01_s2_tid),
      .lane_rcu_res_c01_s3_tid(lane_rcu_res_c01_s3_tid),
      .lane_rcu_res_c02_s0_tid(lane_rcu_res_c02_s0_tid),
      .lane_rcu_res_c02_s1_tid(lane_rcu_res_c02_s1_tid),
      .lane_rcu_res_c02_s2_tid(lane_rcu_res_c02_s2_tid),
      .lane_rcu_res_c02_s3_tid(lane_rcu_res_c02_s3_tid),
      .lane_rcu_res_c03_s0_tid(lane_rcu_res_c03_s0_tid),
      .lane_rcu_res_c03_s1_tid(lane_rcu_res_c03_s1_tid),
      .lane_rcu_res_c03_s2_tid(lane_rcu_res_c03_s2_tid),
      .lane_rcu_res_c03_s3_tid(lane_rcu_res_c03_s3_tid),
      .lane_rcu_res_c04_s0_tid(lane_rcu_res_c04_s0_tid),
      .lane_rcu_res_c04_s1_tid(lane_rcu_res_c04_s1_tid),
      .lane_rcu_res_c04_s2_tid(lane_rcu_res_c04_s2_tid),
      .lane_rcu_res_c04_s3_tid(lane_rcu_res_c04_s3_tid),
      .lane_rcu_res_c05_s0_tid(lane_rcu_res_c05_s0_tid),
      .lane_rcu_res_c05_s1_tid(lane_rcu_res_c05_s1_tid),
      .lane_rcu_res_c05_s2_tid(lane_rcu_res_c05_s2_tid),
      .lane_rcu_res_c05_s3_tid(lane_rcu_res_c05_s3_tid),
      .lane_rcu_res_c06_s0_tid(lane_rcu_res_c06_s0_tid),
      .lane_rcu_res_c06_s1_tid(lane_rcu_res_c06_s1_tid),
      .lane_rcu_res_c06_s2_tid(lane_rcu_res_c06_s2_tid),
      .lane_rcu_res_c06_s3_tid(lane_rcu_res_c06_s3_tid),
      .lane_rcu_res_c07_s0_tid(lane_rcu_res_c07_s0_tid),
      .lane_rcu_res_c07_s1_tid(lane_rcu_res_c07_s1_tid),
      .lane_rcu_res_c07_s2_tid(lane_rcu_res_c07_s2_tid),
      .lane_rcu_res_c07_s3_tid(lane_rcu_res_c07_s3_tid),
      .lane_rcu_res_c08_s0_tid(lane_rcu_res_c08_s0_tid),
      .lane_rcu_res_c08_s1_tid(lane_rcu_res_c08_s1_tid),
      .lane_rcu_res_c08_s2_tid(lane_rcu_res_c08_s2_tid),
      .lane_rcu_res_c08_s3_tid(lane_rcu_res_c08_s3_tid),
      .lane_rcu_res_c09_s0_tid(lane_rcu_res_c09_s0_tid),
      .lane_rcu_res_c09_s1_tid(lane_rcu_res_c09_s1_tid),
      .lane_rcu_res_c09_s2_tid(lane_rcu_res_c09_s2_tid),
      .lane_rcu_res_c09_s3_tid(lane_rcu_res_c09_s3_tid),
      .lane_rcu_res_c10_s0_tid(lane_rcu_res_c10_s0_tid),
      .lane_rcu_res_c10_s1_tid(lane_rcu_res_c10_s1_tid),
      .lane_rcu_res_c10_s2_tid(lane_rcu_res_c10_s2_tid),
      .lane_rcu_res_c10_s3_tid(lane_rcu_res_c10_s3_tid),
      .lane_rcu_res_c11_s0_tid(lane_rcu_res_c11_s0_tid),
      .lane_rcu_res_c11_s1_tid(lane_rcu_res_c11_s1_tid),
      .lane_rcu_res_c11_s2_tid(lane_rcu_res_c11_s2_tid),
      .lane_rcu_res_c11_s3_tid(lane_rcu_res_c11_s3_tid),
      .lane_rcu_res_c12_s0_tid(lane_rcu_res_c12_s0_tid),
      .lane_rcu_res_c12_s1_tid(lane_rcu_res_c12_s1_tid),
      .lane_rcu_res_c12_s2_tid(lane_rcu_res_c12_s2_tid),
      .lane_rcu_res_c12_s3_tid(lane_rcu_res_c12_s3_tid),
      .lane_rcu_res_c13_s0_tid(lane_rcu_res_c13_s0_tid),
      .lane_rcu_res_c13_s1_tid(lane_rcu_res_c13_s1_tid),
      .lane_rcu_res_c13_s2_tid(lane_rcu_res_c13_s2_tid),
      .lane_rcu_res_c13_s3_tid(lane_rcu_res_c13_s3_tid),
      .lane_rcu_res_c14_s0_tid(lane_rcu_res_c14_s0_tid),
      .lane_rcu_res_c14_s1_tid(lane_rcu_res_c14_s1_tid),
      .lane_rcu_res_c14_s2_tid(lane_rcu_res_c14_s2_tid),
      .lane_rcu_res_c14_s3_tid(lane_rcu_res_c14_s3_tid),
      .lane_rcu_res_c15_s0_tid(lane_rcu_res_c15_s0_tid),
      .lane_rcu_res_c15_s1_tid(lane_rcu_res_c15_s1_tid),
      .lane_rcu_res_c15_s2_tid(lane_rcu_res_c15_s2_tid),
      .lane_rcu_res_c15_s3_tid(lane_rcu_res_c15_s3_tid),
      .lane_rcu_res_c16_s0_tid(lane_rcu_res_c16_s0_tid),
      .lane_rcu_res_c16_s1_tid(lane_rcu_res_c16_s1_tid),
      .lane_rcu_res_c16_s2_tid(lane_rcu_res_c16_s2_tid),
      .lane_rcu_res_c16_s3_tid(lane_rcu_res_c16_s3_tid),
      .lane_rcu_res_c17_s0_tid(lane_rcu_res_c17_s0_tid),
      .lane_rcu_res_c17_s1_tid(lane_rcu_res_c17_s1_tid),
      .lane_rcu_res_c17_s2_tid(lane_rcu_res_c17_s2_tid),
      .lane_rcu_res_c17_s3_tid(lane_rcu_res_c17_s3_tid),
      .lane_rcu_res_c18_s0_tid(lane_rcu_res_c18_s0_tid),
      .lane_rcu_res_c18_s1_tid(lane_rcu_res_c18_s1_tid),
      .lane_rcu_res_c18_s2_tid(lane_rcu_res_c18_s2_tid),
      .lane_rcu_res_c18_s3_tid(lane_rcu_res_c18_s3_tid),
      .lane_rcu_res_c19_s0_tid(lane_rcu_res_c19_s0_tid),
      .lane_rcu_res_c19_s1_tid(lane_rcu_res_c19_s1_tid),
      .lane_rcu_res_c19_s2_tid(lane_rcu_res_c19_s2_tid),
      .lane_rcu_res_c19_s3_tid(lane_rcu_res_c19_s3_tid),
      .lane_rcu_res_c20_s0_tid(lane_rcu_res_c20_s0_tid),
      .lane_rcu_res_c20_s1_tid(lane_rcu_res_c20_s1_tid),
      .lane_rcu_res_c20_s2_tid(lane_rcu_res_c20_s2_tid),
      .lane_rcu_res_c20_s3_tid(lane_rcu_res_c20_s3_tid),
      .lane_rcu_res_c21_s0_tid(lane_rcu_res_c21_s0_tid),
      .lane_rcu_res_c21_s1_tid(lane_rcu_res_c21_s1_tid),
      .lane_rcu_res_c21_s2_tid(lane_rcu_res_c21_s2_tid),
      .lane_rcu_res_c21_s3_tid(lane_rcu_res_c21_s3_tid),
      .lane_rcu_res_c22_s0_tid(lane_rcu_res_c22_s0_tid),
      .lane_rcu_res_c22_s1_tid(lane_rcu_res_c22_s1_tid),
      .lane_rcu_res_c22_s2_tid(lane_rcu_res_c22_s2_tid),
      .lane_rcu_res_c22_s3_tid(lane_rcu_res_c22_s3_tid),
      .lane_rcu_res_c23_s0_tid(lane_rcu_res_c23_s0_tid),
      .lane_rcu_res_c23_s1_tid(lane_rcu_res_c23_s1_tid),
      .lane_rcu_res_c23_s2_tid(lane_rcu_res_c23_s2_tid),
      .lane_rcu_res_c23_s3_tid(lane_rcu_res_c23_s3_tid),
      .lane_rcu_res_c24_s0_tid(lane_rcu_res_c24_s0_tid),
      .lane_rcu_res_c24_s1_tid(lane_rcu_res_c24_s1_tid),
      .lane_rcu_res_c24_s2_tid(lane_rcu_res_c24_s2_tid),
      .lane_rcu_res_c24_s3_tid(lane_rcu_res_c24_s3_tid),
      .lane_rcu_res_c25_s0_tid(lane_rcu_res_c25_s0_tid),
      .lane_rcu_res_c25_s1_tid(lane_rcu_res_c25_s1_tid),
      .lane_rcu_res_c25_s2_tid(lane_rcu_res_c25_s2_tid),
      .lane_rcu_res_c25_s3_tid(lane_rcu_res_c25_s3_tid),
      .lane_rcu_res_c26_s0_tid(lane_rcu_res_c26_s0_tid),
      .lane_rcu_res_c26_s1_tid(lane_rcu_res_c26_s1_tid),
      .lane_rcu_res_c26_s2_tid(lane_rcu_res_c26_s2_tid),
      .lane_rcu_res_c26_s3_tid(lane_rcu_res_c26_s3_tid),
      .lane_rcu_res_c27_s0_tid(lane_rcu_res_c27_s0_tid),
      .lane_rcu_res_c27_s1_tid(lane_rcu_res_c27_s1_tid),
      .lane_rcu_res_c27_s2_tid(lane_rcu_res_c27_s2_tid),
      .lane_rcu_res_c27_s3_tid(lane_rcu_res_c27_s3_tid),
      .lane_rcu_res_c28_s0_tid(lane_rcu_res_c28_s0_tid),
      .lane_rcu_res_c28_s1_tid(lane_rcu_res_c28_s1_tid),
      .lane_rcu_res_c28_s2_tid(lane_rcu_res_c28_s2_tid),
      .lane_rcu_res_c28_s3_tid(lane_rcu_res_c28_s3_tid),
      .lane_rcu_res_c29_s0_tid(lane_rcu_res_c29_s0_tid),
      .lane_rcu_res_c29_s1_tid(lane_rcu_res_c29_s1_tid),
      .lane_rcu_res_c29_s2_tid(lane_rcu_res_c29_s2_tid),
      .lane_rcu_res_c29_s3_tid(lane_rcu_res_c29_s3_tid),
      .lane_rcu_res_c30_s0_tid(lane_rcu_res_c30_s0_tid),
      .lane_rcu_res_c30_s1_tid(lane_rcu_res_c30_s1_tid),
      .lane_rcu_res_c30_s2_tid(lane_rcu_res_c30_s2_tid),
      .lane_rcu_res_c30_s3_tid(lane_rcu_res_c30_s3_tid),
      .lane_rcu_res_c31_s0_tid(lane_rcu_res_c31_s0_tid),
      .lane_rcu_res_c31_s1_tid(lane_rcu_res_c31_s1_tid),
      .lane_rcu_res_c31_s2_tid(lane_rcu_res_c31_s2_tid),
      .lane_rcu_res_c31_s3_tid(lane_rcu_res_c31_s3_tid),
      .rcu_ooe_done_s0_tid(rcu_ooe_done_s0_tid),
      .rcu_ooe_done_s1_tid(rcu_ooe_done_s1_tid),
      .rcu_ooe_done_s2_tid(rcu_ooe_done_s2_tid),
      .rcu_ooe_done_s3_tid(rcu_ooe_done_s3_tid),
      .rcu_miu_addr_s0_tid(rcu_miu_addr_s0_tid),
      .rcu_miu_addr_s1_tid(rcu_miu_addr_s1_tid),
      .rcu_miu_addr_s2_tid(rcu_miu_addr_s2_tid),
      .rcu_miu_addr_s3_tid(rcu_miu_addr_s3_tid),
      .miu_rcu_data_s0_tid(miu_rcu_data_s0_tid),
      .miu_rcu_data_s1_tid(miu_rcu_data_s1_tid),
      .miu_rcu_data_s2_tid(miu_rcu_data_s2_tid),
      .miu_rcu_data_s3_tid(miu_rcu_data_s3_tid),
      .rau_rcu_mig_tid(rau_rcu_mig_tid),
      .rcu_pca_mig_tid(rcu_pca_mig_tid),
      .pca_rcu_mig_tid(pca_rcu_mig_tid)
`endif
  );

  ccv_lane u_lane_00 (
    .clk(lane_00_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_00_sleep_ok),
    .csr_req(csr_reqs[196 +: 49]),
    .csr_rsp(csr_rsps[132 +: 33]),
    .csr_credit(csr_credits[4]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c00_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c00_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c00_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c00_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c00_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c00_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c00_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c00_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c00_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c00_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c00_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c00_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c00_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c00_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c00_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c00_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c00_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c00_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c00_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c00_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c00_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c00_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c00_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c00_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c00_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c00_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c00_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c00_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c00_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c00_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c00_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c00_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c00_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c00_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c00_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c00_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c00_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c00_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c00_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c00_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c00_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c00_s3_tid)
`endif
  );

  ccv_lane u_lane_01 (
    .clk(lane_01_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_01_sleep_ok),
    .csr_req(csr_reqs[245 +: 49]),
    .csr_rsp(csr_rsps[165 +: 33]),
    .csr_credit(csr_credits[5]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c01_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c01_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c01_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c01_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c01_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c01_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c01_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c01_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c01_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c01_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c01_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c01_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c01_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c01_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c01_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c01_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c01_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c01_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c01_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c01_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c01_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c01_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c01_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c01_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c01_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c01_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c01_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c01_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c01_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c01_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c01_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c01_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c01_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c01_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c01_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c01_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c01_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c01_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c01_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c01_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c01_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c01_s3_tid)
`endif
  );

  ccv_lane u_lane_02 (
    .clk(lane_02_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_02_sleep_ok),
    .csr_req(csr_reqs[294 +: 49]),
    .csr_rsp(csr_rsps[198 +: 33]),
    .csr_credit(csr_credits[6]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c02_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c02_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c02_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c02_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c02_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c02_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c02_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c02_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c02_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c02_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c02_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c02_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c02_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c02_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c02_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c02_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c02_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c02_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c02_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c02_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c02_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c02_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c02_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c02_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c02_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c02_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c02_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c02_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c02_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c02_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c02_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c02_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c02_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c02_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c02_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c02_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c02_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c02_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c02_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c02_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c02_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c02_s3_tid)
`endif
  );

  ccv_lane u_lane_03 (
    .clk(lane_03_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_03_sleep_ok),
    .csr_req(csr_reqs[343 +: 49]),
    .csr_rsp(csr_rsps[231 +: 33]),
    .csr_credit(csr_credits[7]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c03_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c03_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c03_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c03_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c03_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c03_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c03_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c03_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c03_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c03_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c03_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c03_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c03_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c03_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c03_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c03_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c03_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c03_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c03_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c03_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c03_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c03_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c03_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c03_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c03_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c03_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c03_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c03_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c03_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c03_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c03_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c03_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c03_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c03_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c03_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c03_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c03_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c03_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c03_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c03_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c03_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c03_s3_tid)
`endif
  );

  ccv_lane u_lane_04 (
    .clk(lane_04_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_04_sleep_ok),
    .csr_req(csr_reqs[392 +: 49]),
    .csr_rsp(csr_rsps[264 +: 33]),
    .csr_credit(csr_credits[8]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c04_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c04_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c04_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c04_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c04_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c04_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c04_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c04_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c04_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c04_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c04_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c04_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c04_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c04_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c04_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c04_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c04_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c04_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c04_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c04_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c04_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c04_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c04_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c04_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c04_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c04_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c04_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c04_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c04_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c04_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c04_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c04_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c04_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c04_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c04_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c04_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c04_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c04_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c04_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c04_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c04_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c04_s3_tid)
`endif
  );

  ccv_lane u_lane_05 (
    .clk(lane_05_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_05_sleep_ok),
    .csr_req(csr_reqs[441 +: 49]),
    .csr_rsp(csr_rsps[297 +: 33]),
    .csr_credit(csr_credits[9]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c05_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c05_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c05_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c05_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c05_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c05_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c05_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c05_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c05_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c05_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c05_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c05_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c05_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c05_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c05_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c05_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c05_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c05_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c05_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c05_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c05_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c05_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c05_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c05_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c05_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c05_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c05_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c05_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c05_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c05_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c05_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c05_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c05_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c05_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c05_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c05_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c05_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c05_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c05_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c05_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c05_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c05_s3_tid)
`endif
  );

  ccv_lane u_lane_06 (
    .clk(lane_06_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_06_sleep_ok),
    .csr_req(csr_reqs[490 +: 49]),
    .csr_rsp(csr_rsps[330 +: 33]),
    .csr_credit(csr_credits[10]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c06_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c06_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c06_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c06_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c06_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c06_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c06_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c06_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c06_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c06_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c06_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c06_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c06_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c06_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c06_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c06_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c06_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c06_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c06_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c06_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c06_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c06_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c06_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c06_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c06_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c06_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c06_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c06_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c06_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c06_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c06_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c06_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c06_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c06_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c06_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c06_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c06_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c06_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c06_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c06_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c06_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c06_s3_tid)
`endif
  );

  ccv_lane u_lane_07 (
    .clk(lane_07_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_07_sleep_ok),
    .csr_req(csr_reqs[539 +: 49]),
    .csr_rsp(csr_rsps[363 +: 33]),
    .csr_credit(csr_credits[11]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c07_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c07_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c07_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c07_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c07_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c07_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c07_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c07_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c07_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c07_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c07_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c07_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c07_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c07_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c07_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c07_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c07_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c07_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c07_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c07_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c07_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c07_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c07_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c07_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c07_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c07_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c07_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c07_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c07_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c07_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c07_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c07_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c07_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c07_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c07_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c07_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c07_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c07_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c07_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c07_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c07_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c07_s3_tid)
`endif
  );

  ccv_lane u_lane_08 (
    .clk(lane_08_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_08_sleep_ok),
    .csr_req(csr_reqs[588 +: 49]),
    .csr_rsp(csr_rsps[396 +: 33]),
    .csr_credit(csr_credits[12]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c08_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c08_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c08_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c08_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c08_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c08_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c08_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c08_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c08_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c08_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c08_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c08_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c08_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c08_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c08_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c08_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c08_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c08_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c08_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c08_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c08_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c08_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c08_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c08_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c08_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c08_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c08_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c08_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c08_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c08_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c08_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c08_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c08_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c08_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c08_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c08_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c08_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c08_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c08_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c08_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c08_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c08_s3_tid)
`endif
  );

  ccv_lane u_lane_09 (
    .clk(lane_09_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_09_sleep_ok),
    .csr_req(csr_reqs[637 +: 49]),
    .csr_rsp(csr_rsps[429 +: 33]),
    .csr_credit(csr_credits[13]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c09_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c09_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c09_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c09_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c09_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c09_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c09_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c09_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c09_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c09_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c09_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c09_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c09_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c09_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c09_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c09_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c09_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c09_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c09_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c09_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c09_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c09_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c09_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c09_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c09_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c09_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c09_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c09_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c09_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c09_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c09_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c09_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c09_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c09_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c09_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c09_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c09_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c09_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c09_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c09_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c09_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c09_s3_tid)
`endif
  );

  ccv_lane u_lane_10 (
    .clk(lane_10_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_10_sleep_ok),
    .csr_req(csr_reqs[686 +: 49]),
    .csr_rsp(csr_rsps[462 +: 33]),
    .csr_credit(csr_credits[14]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c10_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c10_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c10_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c10_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c10_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c10_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c10_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c10_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c10_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c10_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c10_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c10_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c10_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c10_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c10_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c10_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c10_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c10_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c10_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c10_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c10_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c10_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c10_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c10_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c10_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c10_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c10_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c10_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c10_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c10_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c10_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c10_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c10_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c10_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c10_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c10_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c10_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c10_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c10_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c10_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c10_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c10_s3_tid)
`endif
  );

  ccv_lane u_lane_11 (
    .clk(lane_11_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_11_sleep_ok),
    .csr_req(csr_reqs[735 +: 49]),
    .csr_rsp(csr_rsps[495 +: 33]),
    .csr_credit(csr_credits[15]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c11_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c11_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c11_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c11_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c11_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c11_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c11_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c11_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c11_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c11_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c11_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c11_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c11_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c11_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c11_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c11_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c11_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c11_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c11_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c11_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c11_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c11_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c11_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c11_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c11_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c11_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c11_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c11_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c11_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c11_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c11_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c11_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c11_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c11_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c11_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c11_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c11_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c11_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c11_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c11_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c11_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c11_s3_tid)
`endif
  );

  ccv_lane u_lane_12 (
    .clk(lane_12_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_12_sleep_ok),
    .csr_req(csr_reqs[784 +: 49]),
    .csr_rsp(csr_rsps[528 +: 33]),
    .csr_credit(csr_credits[16]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c12_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c12_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c12_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c12_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c12_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c12_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c12_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c12_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c12_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c12_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c12_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c12_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c12_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c12_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c12_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c12_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c12_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c12_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c12_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c12_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c12_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c12_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c12_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c12_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c12_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c12_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c12_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c12_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c12_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c12_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c12_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c12_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c12_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c12_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c12_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c12_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c12_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c12_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c12_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c12_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c12_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c12_s3_tid)
`endif
  );

  ccv_lane u_lane_13 (
    .clk(lane_13_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_13_sleep_ok),
    .csr_req(csr_reqs[833 +: 49]),
    .csr_rsp(csr_rsps[561 +: 33]),
    .csr_credit(csr_credits[17]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c13_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c13_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c13_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c13_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c13_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c13_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c13_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c13_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c13_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c13_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c13_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c13_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c13_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c13_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c13_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c13_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c13_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c13_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c13_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c13_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c13_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c13_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c13_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c13_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c13_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c13_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c13_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c13_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c13_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c13_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c13_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c13_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c13_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c13_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c13_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c13_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c13_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c13_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c13_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c13_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c13_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c13_s3_tid)
`endif
  );

  ccv_lane u_lane_14 (
    .clk(lane_14_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_14_sleep_ok),
    .csr_req(csr_reqs[882 +: 49]),
    .csr_rsp(csr_rsps[594 +: 33]),
    .csr_credit(csr_credits[18]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c14_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c14_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c14_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c14_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c14_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c14_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c14_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c14_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c14_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c14_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c14_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c14_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c14_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c14_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c14_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c14_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c14_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c14_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c14_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c14_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c14_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c14_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c14_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c14_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c14_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c14_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c14_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c14_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c14_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c14_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c14_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c14_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c14_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c14_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c14_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c14_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c14_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c14_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c14_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c14_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c14_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c14_s3_tid)
`endif
  );

  ccv_lane u_lane_15 (
    .clk(lane_15_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_15_sleep_ok),
    .csr_req(csr_reqs[931 +: 49]),
    .csr_rsp(csr_rsps[627 +: 33]),
    .csr_credit(csr_credits[19]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c15_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c15_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c15_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c15_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c15_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c15_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c15_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c15_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c15_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c15_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c15_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c15_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c15_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c15_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c15_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c15_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c15_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c15_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c15_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c15_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c15_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c15_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c15_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c15_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c15_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c15_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c15_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c15_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c15_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c15_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c15_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c15_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c15_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c15_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c15_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c15_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c15_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c15_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c15_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c15_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c15_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c15_s3_tid)
`endif
  );

  ccv_lane u_lane_16 (
    .clk(lane_16_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_16_sleep_ok),
    .csr_req(csr_reqs[980 +: 49]),
    .csr_rsp(csr_rsps[660 +: 33]),
    .csr_credit(csr_credits[20]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c16_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c16_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c16_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c16_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c16_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c16_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c16_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c16_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c16_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c16_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c16_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c16_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c16_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c16_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c16_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c16_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c16_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c16_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c16_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c16_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c16_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c16_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c16_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c16_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c16_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c16_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c16_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c16_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c16_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c16_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c16_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c16_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c16_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c16_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c16_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c16_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c16_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c16_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c16_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c16_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c16_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c16_s3_tid)
`endif
  );

  ccv_lane u_lane_17 (
    .clk(lane_17_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_17_sleep_ok),
    .csr_req(csr_reqs[1029 +: 49]),
    .csr_rsp(csr_rsps[693 +: 33]),
    .csr_credit(csr_credits[21]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c17_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c17_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c17_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c17_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c17_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c17_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c17_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c17_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c17_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c17_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c17_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c17_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c17_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c17_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c17_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c17_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c17_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c17_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c17_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c17_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c17_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c17_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c17_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c17_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c17_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c17_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c17_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c17_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c17_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c17_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c17_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c17_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c17_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c17_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c17_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c17_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c17_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c17_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c17_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c17_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c17_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c17_s3_tid)
`endif
  );

  ccv_lane u_lane_18 (
    .clk(lane_18_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_18_sleep_ok),
    .csr_req(csr_reqs[1078 +: 49]),
    .csr_rsp(csr_rsps[726 +: 33]),
    .csr_credit(csr_credits[22]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c18_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c18_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c18_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c18_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c18_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c18_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c18_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c18_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c18_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c18_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c18_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c18_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c18_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c18_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c18_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c18_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c18_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c18_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c18_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c18_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c18_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c18_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c18_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c18_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c18_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c18_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c18_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c18_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c18_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c18_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c18_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c18_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c18_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c18_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c18_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c18_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c18_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c18_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c18_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c18_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c18_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c18_s3_tid)
`endif
  );

  ccv_lane u_lane_19 (
    .clk(lane_19_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_19_sleep_ok),
    .csr_req(csr_reqs[1127 +: 49]),
    .csr_rsp(csr_rsps[759 +: 33]),
    .csr_credit(csr_credits[23]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c19_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c19_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c19_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c19_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c19_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c19_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c19_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c19_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c19_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c19_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c19_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c19_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c19_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c19_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c19_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c19_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c19_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c19_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c19_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c19_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c19_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c19_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c19_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c19_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c19_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c19_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c19_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c19_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c19_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c19_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c19_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c19_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c19_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c19_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c19_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c19_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c19_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c19_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c19_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c19_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c19_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c19_s3_tid)
`endif
  );

  ccv_lane u_lane_20 (
    .clk(lane_20_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_20_sleep_ok),
    .csr_req(csr_reqs[1176 +: 49]),
    .csr_rsp(csr_rsps[792 +: 33]),
    .csr_credit(csr_credits[24]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c20_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c20_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c20_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c20_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c20_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c20_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c20_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c20_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c20_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c20_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c20_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c20_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c20_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c20_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c20_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c20_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c20_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c20_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c20_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c20_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c20_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c20_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c20_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c20_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c20_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c20_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c20_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c20_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c20_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c20_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c20_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c20_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c20_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c20_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c20_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c20_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c20_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c20_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c20_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c20_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c20_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c20_s3_tid)
`endif
  );

  ccv_lane u_lane_21 (
    .clk(lane_21_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_21_sleep_ok),
    .csr_req(csr_reqs[1225 +: 49]),
    .csr_rsp(csr_rsps[825 +: 33]),
    .csr_credit(csr_credits[25]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c21_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c21_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c21_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c21_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c21_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c21_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c21_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c21_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c21_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c21_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c21_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c21_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c21_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c21_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c21_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c21_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c21_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c21_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c21_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c21_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c21_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c21_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c21_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c21_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c21_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c21_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c21_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c21_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c21_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c21_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c21_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c21_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c21_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c21_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c21_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c21_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c21_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c21_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c21_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c21_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c21_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c21_s3_tid)
`endif
  );

  ccv_lane u_lane_22 (
    .clk(lane_22_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_22_sleep_ok),
    .csr_req(csr_reqs[1274 +: 49]),
    .csr_rsp(csr_rsps[858 +: 33]),
    .csr_credit(csr_credits[26]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c22_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c22_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c22_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c22_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c22_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c22_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c22_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c22_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c22_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c22_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c22_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c22_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c22_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c22_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c22_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c22_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c22_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c22_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c22_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c22_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c22_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c22_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c22_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c22_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c22_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c22_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c22_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c22_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c22_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c22_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c22_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c22_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c22_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c22_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c22_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c22_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c22_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c22_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c22_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c22_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c22_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c22_s3_tid)
`endif
  );

  ccv_lane u_lane_23 (
    .clk(lane_23_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_23_sleep_ok),
    .csr_req(csr_reqs[1323 +: 49]),
    .csr_rsp(csr_rsps[891 +: 33]),
    .csr_credit(csr_credits[27]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c23_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c23_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c23_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c23_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c23_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c23_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c23_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c23_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c23_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c23_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c23_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c23_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c23_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c23_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c23_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c23_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c23_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c23_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c23_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c23_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c23_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c23_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c23_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c23_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c23_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c23_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c23_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c23_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c23_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c23_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c23_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c23_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c23_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c23_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c23_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c23_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c23_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c23_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c23_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c23_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c23_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c23_s3_tid)
`endif
  );

  ccv_lane u_lane_24 (
    .clk(lane_24_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_24_sleep_ok),
    .csr_req(csr_reqs[1372 +: 49]),
    .csr_rsp(csr_rsps[924 +: 33]),
    .csr_credit(csr_credits[28]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c24_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c24_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c24_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c24_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c24_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c24_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c24_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c24_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c24_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c24_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c24_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c24_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c24_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c24_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c24_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c24_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c24_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c24_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c24_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c24_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c24_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c24_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c24_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c24_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c24_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c24_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c24_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c24_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c24_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c24_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c24_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c24_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c24_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c24_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c24_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c24_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c24_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c24_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c24_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c24_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c24_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c24_s3_tid)
`endif
  );

  ccv_lane u_lane_25 (
    .clk(lane_25_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_25_sleep_ok),
    .csr_req(csr_reqs[1421 +: 49]),
    .csr_rsp(csr_rsps[957 +: 33]),
    .csr_credit(csr_credits[29]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c25_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c25_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c25_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c25_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c25_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c25_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c25_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c25_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c25_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c25_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c25_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c25_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c25_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c25_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c25_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c25_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c25_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c25_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c25_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c25_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c25_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c25_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c25_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c25_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c25_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c25_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c25_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c25_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c25_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c25_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c25_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c25_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c25_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c25_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c25_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c25_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c25_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c25_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c25_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c25_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c25_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c25_s3_tid)
`endif
  );

  ccv_lane u_lane_26 (
    .clk(lane_26_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_26_sleep_ok),
    .csr_req(csr_reqs[1470 +: 49]),
    .csr_rsp(csr_rsps[990 +: 33]),
    .csr_credit(csr_credits[30]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c26_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c26_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c26_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c26_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c26_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c26_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c26_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c26_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c26_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c26_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c26_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c26_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c26_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c26_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c26_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c26_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c26_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c26_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c26_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c26_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c26_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c26_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c26_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c26_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c26_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c26_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c26_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c26_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c26_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c26_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c26_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c26_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c26_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c26_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c26_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c26_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c26_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c26_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c26_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c26_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c26_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c26_s3_tid)
`endif
  );

  ccv_lane u_lane_27 (
    .clk(lane_27_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_27_sleep_ok),
    .csr_req(csr_reqs[1519 +: 49]),
    .csr_rsp(csr_rsps[1023 +: 33]),
    .csr_credit(csr_credits[31]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c27_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c27_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c27_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c27_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c27_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c27_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c27_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c27_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c27_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c27_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c27_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c27_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c27_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c27_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c27_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c27_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c27_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c27_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c27_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c27_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c27_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c27_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c27_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c27_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c27_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c27_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c27_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c27_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c27_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c27_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c27_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c27_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c27_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c27_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c27_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c27_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c27_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c27_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c27_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c27_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c27_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c27_s3_tid)
`endif
  );

  ccv_lane u_lane_28 (
    .clk(lane_28_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_28_sleep_ok),
    .csr_req(csr_reqs[1568 +: 49]),
    .csr_rsp(csr_rsps[1056 +: 33]),
    .csr_credit(csr_credits[32]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c28_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c28_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c28_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c28_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c28_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c28_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c28_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c28_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c28_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c28_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c28_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c28_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c28_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c28_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c28_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c28_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c28_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c28_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c28_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c28_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c28_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c28_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c28_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c28_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c28_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c28_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c28_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c28_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c28_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c28_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c28_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c28_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c28_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c28_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c28_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c28_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c28_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c28_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c28_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c28_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c28_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c28_s3_tid)
`endif
  );

  ccv_lane u_lane_29 (
    .clk(lane_29_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_29_sleep_ok),
    .csr_req(csr_reqs[1617 +: 49]),
    .csr_rsp(csr_rsps[1089 +: 33]),
    .csr_credit(csr_credits[33]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c29_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c29_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c29_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c29_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c29_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c29_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c29_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c29_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c29_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c29_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c29_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c29_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c29_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c29_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c29_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c29_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c29_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c29_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c29_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c29_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c29_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c29_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c29_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c29_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c29_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c29_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c29_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c29_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c29_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c29_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c29_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c29_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c29_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c29_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c29_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c29_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c29_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c29_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c29_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c29_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c29_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c29_s3_tid)
`endif
  );

  ccv_lane u_lane_30 (
    .clk(lane_30_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_30_sleep_ok),
    .csr_req(csr_reqs[1666 +: 49]),
    .csr_rsp(csr_rsps[1122 +: 33]),
    .csr_credit(csr_credits[34]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c30_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c30_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c30_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c30_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c30_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c30_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c30_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c30_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c30_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c30_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c30_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c30_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c30_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c30_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c30_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c30_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c30_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c30_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c30_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c30_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c30_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c30_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c30_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c30_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c30_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c30_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c30_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c30_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c30_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c30_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c30_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c30_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c30_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c30_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c30_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c30_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c30_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c30_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c30_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c30_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c30_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c30_s3_tid)
`endif
  );

  ccv_lane u_lane_31 (
    .clk(lane_31_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(lane_31_sleep_ok),
    .csr_req(csr_reqs[1715 +: 49]),
    .csr_rsp(csr_rsps[1155 +: 33]),
    .csr_credit(csr_credits[35]),
    .rcu_lane_ops_s0_valid(rcu_lane_ops_c31_s0_valid),
    .rcu_lane_ops_s0_payload(rcu_lane_ops_c31_s0_payload),
    .rcu_lane_ops_s0_credit(rcu_lane_ops_c31_s0_credit),
    .rcu_lane_ops_s0_stall(rcu_lane_ops_c31_s0_stall),
    .rcu_lane_ops_s1_valid(rcu_lane_ops_c31_s1_valid),
    .rcu_lane_ops_s1_payload(rcu_lane_ops_c31_s1_payload),
    .rcu_lane_ops_s1_credit(rcu_lane_ops_c31_s1_credit),
    .rcu_lane_ops_s1_stall(rcu_lane_ops_c31_s1_stall),
    .rcu_lane_ops_s2_valid(rcu_lane_ops_c31_s2_valid),
    .rcu_lane_ops_s2_payload(rcu_lane_ops_c31_s2_payload),
    .rcu_lane_ops_s2_credit(rcu_lane_ops_c31_s2_credit),
    .rcu_lane_ops_s2_stall(rcu_lane_ops_c31_s2_stall),
    .rcu_lane_ops_s3_valid(rcu_lane_ops_c31_s3_valid),
    .rcu_lane_ops_s3_payload(rcu_lane_ops_c31_s3_payload),
    .rcu_lane_ops_s3_credit(rcu_lane_ops_c31_s3_credit),
    .rcu_lane_ops_s3_stall(rcu_lane_ops_c31_s3_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_c31_wake),
    .lane_rcu_res_s0_valid(lane_rcu_res_c31_s0_valid),
    .lane_rcu_res_s0_payload(lane_rcu_res_c31_s0_payload),
    .lane_rcu_res_s0_credit(lane_rcu_res_c31_s0_credit),
    .lane_rcu_res_s0_stall(lane_rcu_res_c31_s0_stall),
    .lane_rcu_res_s1_valid(lane_rcu_res_c31_s1_valid),
    .lane_rcu_res_s1_payload(lane_rcu_res_c31_s1_payload),
    .lane_rcu_res_s1_credit(lane_rcu_res_c31_s1_credit),
    .lane_rcu_res_s1_stall(lane_rcu_res_c31_s1_stall),
    .lane_rcu_res_s2_valid(lane_rcu_res_c31_s2_valid),
    .lane_rcu_res_s2_payload(lane_rcu_res_c31_s2_payload),
    .lane_rcu_res_s2_credit(lane_rcu_res_c31_s2_credit),
    .lane_rcu_res_s2_stall(lane_rcu_res_c31_s2_stall),
    .lane_rcu_res_s3_valid(lane_rcu_res_c31_s3_valid),
    .lane_rcu_res_s3_payload(lane_rcu_res_c31_s3_payload),
    .lane_rcu_res_s3_credit(lane_rcu_res_c31_s3_credit),
    .lane_rcu_res_s3_stall(lane_rcu_res_c31_s3_stall),
    .lane_rcu_res_wake(lane_rcu_res_c31_wake)
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(rcu_lane_ops_c31_s0_tid),
      .rcu_lane_ops_s1_tid(rcu_lane_ops_c31_s1_tid),
      .rcu_lane_ops_s2_tid(rcu_lane_ops_c31_s2_tid),
      .rcu_lane_ops_s3_tid(rcu_lane_ops_c31_s3_tid),
      .lane_rcu_res_s0_tid(lane_rcu_res_c31_s0_tid),
      .lane_rcu_res_s1_tid(lane_rcu_res_c31_s1_tid),
      .lane_rcu_res_s2_tid(lane_rcu_res_c31_s2_tid),
      .lane_rcu_res_s3_tid(lane_rcu_res_c31_s3_tid)
`endif
  );

  ccv_miu u_miu (
    .clk(miu_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[4]),
    .kill_ack_epoch(kill_ack_epoch[8 +: 2]),
    .sleep_ok(miu_sleep_ok),
    .csr_req(csr_reqs[1764 +: 49]),
    .csr_rsp(csr_rsps[1188 +: 33]),
    .csr_credit(csr_credits[36]),
    .rcu_miu_addr_s0_valid(rcu_miu_addr_s0_valid),
    .rcu_miu_addr_s0_payload(rcu_miu_addr_s0_payload),
    .rcu_miu_addr_s0_credit(rcu_miu_addr_s0_credit),
    .rcu_miu_addr_s0_stall(rcu_miu_addr_s0_stall),
    .rcu_miu_addr_s1_valid(rcu_miu_addr_s1_valid),
    .rcu_miu_addr_s1_payload(rcu_miu_addr_s1_payload),
    .rcu_miu_addr_s1_credit(rcu_miu_addr_s1_credit),
    .rcu_miu_addr_s1_stall(rcu_miu_addr_s1_stall),
    .rcu_miu_addr_s2_valid(rcu_miu_addr_s2_valid),
    .rcu_miu_addr_s2_payload(rcu_miu_addr_s2_payload),
    .rcu_miu_addr_s2_credit(rcu_miu_addr_s2_credit),
    .rcu_miu_addr_s2_stall(rcu_miu_addr_s2_stall),
    .rcu_miu_addr_s3_valid(rcu_miu_addr_s3_valid),
    .rcu_miu_addr_s3_payload(rcu_miu_addr_s3_payload),
    .rcu_miu_addr_s3_credit(rcu_miu_addr_s3_credit),
    .rcu_miu_addr_s3_stall(rcu_miu_addr_s3_stall),
    .rcu_miu_addr_wake(rcu_miu_addr_wake),
    .miu_rcu_data_s0_valid(miu_rcu_data_s0_valid),
    .miu_rcu_data_s0_payload(miu_rcu_data_s0_payload),
    .miu_rcu_data_s0_credit(miu_rcu_data_s0_credit),
    .miu_rcu_data_s0_stall(miu_rcu_data_s0_stall),
    .miu_rcu_data_s1_valid(miu_rcu_data_s1_valid),
    .miu_rcu_data_s1_payload(miu_rcu_data_s1_payload),
    .miu_rcu_data_s1_credit(miu_rcu_data_s1_credit),
    .miu_rcu_data_s1_stall(miu_rcu_data_s1_stall),
    .miu_rcu_data_s2_valid(miu_rcu_data_s2_valid),
    .miu_rcu_data_s2_payload(miu_rcu_data_s2_payload),
    .miu_rcu_data_s2_credit(miu_rcu_data_s2_credit),
    .miu_rcu_data_s2_stall(miu_rcu_data_s2_stall),
    .miu_rcu_data_s3_valid(miu_rcu_data_s3_valid),
    .miu_rcu_data_s3_payload(miu_rcu_data_s3_payload),
    .miu_rcu_data_s3_credit(miu_rcu_data_s3_credit),
    .miu_rcu_data_s3_stall(miu_rcu_data_s3_stall),
    .miu_rcu_data_wake(miu_rcu_data_wake),
    .ooe_miu_memop_s0_valid(ooe_miu_memop_s0_valid),
    .ooe_miu_memop_s0_payload(ooe_miu_memop_s0_payload),
    .ooe_miu_memop_s0_credit(ooe_miu_memop_s0_credit),
    .ooe_miu_memop_s0_stall(ooe_miu_memop_s0_stall),
    .ooe_miu_memop_s1_valid(ooe_miu_memop_s1_valid),
    .ooe_miu_memop_s1_payload(ooe_miu_memop_s1_payload),
    .ooe_miu_memop_s1_credit(ooe_miu_memop_s1_credit),
    .ooe_miu_memop_s1_stall(ooe_miu_memop_s1_stall),
    .ooe_miu_memop_s2_valid(ooe_miu_memop_s2_valid),
    .ooe_miu_memop_s2_payload(ooe_miu_memop_s2_payload),
    .ooe_miu_memop_s2_credit(ooe_miu_memop_s2_credit),
    .ooe_miu_memop_s2_stall(ooe_miu_memop_s2_stall),
    .ooe_miu_memop_s3_valid(ooe_miu_memop_s3_valid),
    .ooe_miu_memop_s3_payload(ooe_miu_memop_s3_payload),
    .ooe_miu_memop_s3_credit(ooe_miu_memop_s3_credit),
    .ooe_miu_memop_s3_stall(ooe_miu_memop_s3_stall),
    .ooe_miu_memop_wake(ooe_miu_memop_wake),
    .miu_ooe_cmpl_s0_valid(miu_ooe_cmpl_s0_valid),
    .miu_ooe_cmpl_s0_payload(miu_ooe_cmpl_s0_payload),
    .miu_ooe_cmpl_s0_credit(miu_ooe_cmpl_s0_credit),
    .miu_ooe_cmpl_s0_stall(miu_ooe_cmpl_s0_stall),
    .miu_ooe_cmpl_s1_valid(miu_ooe_cmpl_s1_valid),
    .miu_ooe_cmpl_s1_payload(miu_ooe_cmpl_s1_payload),
    .miu_ooe_cmpl_s1_credit(miu_ooe_cmpl_s1_credit),
    .miu_ooe_cmpl_s1_stall(miu_ooe_cmpl_s1_stall),
    .miu_ooe_cmpl_s2_valid(miu_ooe_cmpl_s2_valid),
    .miu_ooe_cmpl_s2_payload(miu_ooe_cmpl_s2_payload),
    .miu_ooe_cmpl_s2_credit(miu_ooe_cmpl_s2_credit),
    .miu_ooe_cmpl_s2_stall(miu_ooe_cmpl_s2_stall),
    .miu_ooe_cmpl_s3_valid(miu_ooe_cmpl_s3_valid),
    .miu_ooe_cmpl_s3_payload(miu_ooe_cmpl_s3_payload),
    .miu_ooe_cmpl_s3_credit(miu_ooe_cmpl_s3_credit),
    .miu_ooe_cmpl_s3_stall(miu_ooe_cmpl_s3_stall),
    .miu_ooe_cmpl_wake(miu_ooe_cmpl_wake),
    .ooe_miu_retire_s0_valid(ooe_miu_retire_s0_valid),
    .ooe_miu_retire_s0_payload(ooe_miu_retire_s0_payload),
    .ooe_miu_retire_s0_credit(ooe_miu_retire_s0_credit),
    .ooe_miu_retire_s0_stall(ooe_miu_retire_s0_stall),
    .ooe_miu_retire_s1_valid(ooe_miu_retire_s1_valid),
    .ooe_miu_retire_s1_payload(ooe_miu_retire_s1_payload),
    .ooe_miu_retire_s1_credit(ooe_miu_retire_s1_credit),
    .ooe_miu_retire_s1_stall(ooe_miu_retire_s1_stall),
    .ooe_miu_retire_s2_valid(ooe_miu_retire_s2_valid),
    .ooe_miu_retire_s2_payload(ooe_miu_retire_s2_payload),
    .ooe_miu_retire_s2_credit(ooe_miu_retire_s2_credit),
    .ooe_miu_retire_s2_stall(ooe_miu_retire_s2_stall),
    .ooe_miu_retire_s3_valid(ooe_miu_retire_s3_valid),
    .ooe_miu_retire_s3_payload(ooe_miu_retire_s3_payload),
    .ooe_miu_retire_s3_credit(ooe_miu_retire_s3_credit),
    .ooe_miu_retire_s3_stall(ooe_miu_retire_s3_stall),
    .ooe_miu_retire_wake(ooe_miu_retire_wake),
    .miu_spm_req_s0_valid(miu_spm_req_s0_valid),
    .miu_spm_req_s0_payload(miu_spm_req_s0_payload),
    .miu_spm_req_s0_credit(miu_spm_req_s0_credit),
    .miu_spm_req_s0_stall(miu_spm_req_s0_stall),
    .miu_spm_req_s1_valid(miu_spm_req_s1_valid),
    .miu_spm_req_s1_payload(miu_spm_req_s1_payload),
    .miu_spm_req_s1_credit(miu_spm_req_s1_credit),
    .miu_spm_req_s1_stall(miu_spm_req_s1_stall),
    .miu_spm_req_s2_valid(miu_spm_req_s2_valid),
    .miu_spm_req_s2_payload(miu_spm_req_s2_payload),
    .miu_spm_req_s2_credit(miu_spm_req_s2_credit),
    .miu_spm_req_s2_stall(miu_spm_req_s2_stall),
    .miu_spm_req_s3_valid(miu_spm_req_s3_valid),
    .miu_spm_req_s3_payload(miu_spm_req_s3_payload),
    .miu_spm_req_s3_credit(miu_spm_req_s3_credit),
    .miu_spm_req_s3_stall(miu_spm_req_s3_stall),
    .miu_spm_req_wake(miu_spm_req_wake),
    .spm_miu_rsp_s0_valid(spm_miu_rsp_s0_valid),
    .spm_miu_rsp_s0_payload(spm_miu_rsp_s0_payload),
    .spm_miu_rsp_s0_credit(spm_miu_rsp_s0_credit),
    .spm_miu_rsp_s0_stall(spm_miu_rsp_s0_stall),
    .spm_miu_rsp_s1_valid(spm_miu_rsp_s1_valid),
    .spm_miu_rsp_s1_payload(spm_miu_rsp_s1_payload),
    .spm_miu_rsp_s1_credit(spm_miu_rsp_s1_credit),
    .spm_miu_rsp_s1_stall(spm_miu_rsp_s1_stall),
    .spm_miu_rsp_s2_valid(spm_miu_rsp_s2_valid),
    .spm_miu_rsp_s2_payload(spm_miu_rsp_s2_payload),
    .spm_miu_rsp_s2_credit(spm_miu_rsp_s2_credit),
    .spm_miu_rsp_s2_stall(spm_miu_rsp_s2_stall),
    .spm_miu_rsp_s3_valid(spm_miu_rsp_s3_valid),
    .spm_miu_rsp_s3_payload(spm_miu_rsp_s3_payload),
    .spm_miu_rsp_s3_credit(spm_miu_rsp_s3_credit),
    .spm_miu_rsp_s3_stall(spm_miu_rsp_s3_stall),
    .spm_miu_rsp_wake(spm_miu_rsp_wake),
    .miu_dcu_req_s0_valid(miu_dcu_req_s0_valid),
    .miu_dcu_req_s0_payload(miu_dcu_req_s0_payload),
    .miu_dcu_req_s0_credit(miu_dcu_req_s0_credit),
    .miu_dcu_req_s0_stall(miu_dcu_req_s0_stall),
    .miu_dcu_req_s1_valid(miu_dcu_req_s1_valid),
    .miu_dcu_req_s1_payload(miu_dcu_req_s1_payload),
    .miu_dcu_req_s1_credit(miu_dcu_req_s1_credit),
    .miu_dcu_req_s1_stall(miu_dcu_req_s1_stall),
    .miu_dcu_req_s2_valid(miu_dcu_req_s2_valid),
    .miu_dcu_req_s2_payload(miu_dcu_req_s2_payload),
    .miu_dcu_req_s2_credit(miu_dcu_req_s2_credit),
    .miu_dcu_req_s2_stall(miu_dcu_req_s2_stall),
    .miu_dcu_req_s3_valid(miu_dcu_req_s3_valid),
    .miu_dcu_req_s3_payload(miu_dcu_req_s3_payload),
    .miu_dcu_req_s3_credit(miu_dcu_req_s3_credit),
    .miu_dcu_req_s3_stall(miu_dcu_req_s3_stall),
    .miu_dcu_req_wake(miu_dcu_req_wake),
    .dcu_miu_rsp_s0_valid(dcu_miu_rsp_s0_valid),
    .dcu_miu_rsp_s0_payload(dcu_miu_rsp_s0_payload),
    .dcu_miu_rsp_s0_credit(dcu_miu_rsp_s0_credit),
    .dcu_miu_rsp_s0_stall(dcu_miu_rsp_s0_stall),
    .dcu_miu_rsp_s1_valid(dcu_miu_rsp_s1_valid),
    .dcu_miu_rsp_s1_payload(dcu_miu_rsp_s1_payload),
    .dcu_miu_rsp_s1_credit(dcu_miu_rsp_s1_credit),
    .dcu_miu_rsp_s1_stall(dcu_miu_rsp_s1_stall),
    .dcu_miu_rsp_s2_valid(dcu_miu_rsp_s2_valid),
    .dcu_miu_rsp_s2_payload(dcu_miu_rsp_s2_payload),
    .dcu_miu_rsp_s2_credit(dcu_miu_rsp_s2_credit),
    .dcu_miu_rsp_s2_stall(dcu_miu_rsp_s2_stall),
    .dcu_miu_rsp_s3_valid(dcu_miu_rsp_s3_valid),
    .dcu_miu_rsp_s3_payload(dcu_miu_rsp_s3_payload),
    .dcu_miu_rsp_s3_credit(dcu_miu_rsp_s3_credit),
    .dcu_miu_rsp_s3_stall(dcu_miu_rsp_s3_stall),
    .dcu_miu_rsp_wake(dcu_miu_rsp_wake),
    .miu_fet_itlb_valid(miu_fet_itlb_valid),
    .miu_fet_itlb_payload(miu_fet_itlb_payload),
    .miu_fet_itlb_credit(miu_fet_itlb_credit),
    .miu_fet_itlb_stall(miu_fet_itlb_stall),
    .miu_fet_itlb_wake(miu_fet_itlb_wake),
    .fet_miu_itlb_req_valid(fet_miu_itlb_req_valid),
    .fet_miu_itlb_req_payload(fet_miu_itlb_req_payload),
    .fet_miu_itlb_req_credit(fet_miu_itlb_req_credit),
    .fet_miu_itlb_req_stall(fet_miu_itlb_req_stall),
    .fet_miu_itlb_req_wake(fet_miu_itlb_req_wake),
    .rau_miu_cta_valid(rau_miu_cta_valid),
    .rau_miu_cta_payload(rau_miu_cta_payload),
    .rau_miu_cta_credit(rau_miu_cta_credit),
    .rau_miu_cta_stall(rau_miu_cta_stall),
    .rau_miu_cta_wake(rau_miu_cta_wake)
`ifdef CCV_TRACE
    , .rcu_miu_addr_s0_tid(rcu_miu_addr_s0_tid),
      .rcu_miu_addr_s1_tid(rcu_miu_addr_s1_tid),
      .rcu_miu_addr_s2_tid(rcu_miu_addr_s2_tid),
      .rcu_miu_addr_s3_tid(rcu_miu_addr_s3_tid),
      .miu_rcu_data_s0_tid(miu_rcu_data_s0_tid),
      .miu_rcu_data_s1_tid(miu_rcu_data_s1_tid),
      .miu_rcu_data_s2_tid(miu_rcu_data_s2_tid),
      .miu_rcu_data_s3_tid(miu_rcu_data_s3_tid),
      .ooe_miu_memop_s0_tid(ooe_miu_memop_s0_tid),
      .ooe_miu_memop_s1_tid(ooe_miu_memop_s1_tid),
      .ooe_miu_memop_s2_tid(ooe_miu_memop_s2_tid),
      .ooe_miu_memop_s3_tid(ooe_miu_memop_s3_tid),
      .miu_ooe_cmpl_s0_tid(miu_ooe_cmpl_s0_tid),
      .miu_ooe_cmpl_s1_tid(miu_ooe_cmpl_s1_tid),
      .miu_ooe_cmpl_s2_tid(miu_ooe_cmpl_s2_tid),
      .miu_ooe_cmpl_s3_tid(miu_ooe_cmpl_s3_tid),
      .ooe_miu_retire_s0_tid(ooe_miu_retire_s0_tid),
      .ooe_miu_retire_s1_tid(ooe_miu_retire_s1_tid),
      .ooe_miu_retire_s2_tid(ooe_miu_retire_s2_tid),
      .ooe_miu_retire_s3_tid(ooe_miu_retire_s3_tid),
      .miu_spm_req_s0_tid(miu_spm_req_s0_tid),
      .miu_spm_req_s1_tid(miu_spm_req_s1_tid),
      .miu_spm_req_s2_tid(miu_spm_req_s2_tid),
      .miu_spm_req_s3_tid(miu_spm_req_s3_tid),
      .spm_miu_rsp_s0_tid(spm_miu_rsp_s0_tid),
      .spm_miu_rsp_s1_tid(spm_miu_rsp_s1_tid),
      .spm_miu_rsp_s2_tid(spm_miu_rsp_s2_tid),
      .spm_miu_rsp_s3_tid(spm_miu_rsp_s3_tid),
      .miu_dcu_req_s0_tid(miu_dcu_req_s0_tid),
      .miu_dcu_req_s1_tid(miu_dcu_req_s1_tid),
      .miu_dcu_req_s2_tid(miu_dcu_req_s2_tid),
      .miu_dcu_req_s3_tid(miu_dcu_req_s3_tid),
      .dcu_miu_rsp_s0_tid(dcu_miu_rsp_s0_tid),
      .dcu_miu_rsp_s1_tid(dcu_miu_rsp_s1_tid),
      .dcu_miu_rsp_s2_tid(dcu_miu_rsp_s2_tid),
      .dcu_miu_rsp_s3_tid(dcu_miu_rsp_s3_tid),
      .miu_fet_itlb_tid(miu_fet_itlb_tid),
      .fet_miu_itlb_req_tid(fet_miu_itlb_req_tid),
      .rau_miu_cta_tid(rau_miu_cta_tid)
`endif
  );

  ccv_spm u_spm (
    .clk(spm_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[5]),
    .kill_ack_epoch(kill_ack_epoch[10 +: 2]),
    .sleep_ok(spm_sleep_ok),
    .csr_req(csr_reqs[1813 +: 49]),
    .csr_rsp(csr_rsps[1221 +: 33]),
    .csr_credit(csr_credits[37]),
    .miu_spm_req_s0_valid(miu_spm_req_s0_valid),
    .miu_spm_req_s0_payload(miu_spm_req_s0_payload),
    .miu_spm_req_s0_credit(miu_spm_req_s0_credit),
    .miu_spm_req_s0_stall(miu_spm_req_s0_stall),
    .miu_spm_req_s1_valid(miu_spm_req_s1_valid),
    .miu_spm_req_s1_payload(miu_spm_req_s1_payload),
    .miu_spm_req_s1_credit(miu_spm_req_s1_credit),
    .miu_spm_req_s1_stall(miu_spm_req_s1_stall),
    .miu_spm_req_s2_valid(miu_spm_req_s2_valid),
    .miu_spm_req_s2_payload(miu_spm_req_s2_payload),
    .miu_spm_req_s2_credit(miu_spm_req_s2_credit),
    .miu_spm_req_s2_stall(miu_spm_req_s2_stall),
    .miu_spm_req_s3_valid(miu_spm_req_s3_valid),
    .miu_spm_req_s3_payload(miu_spm_req_s3_payload),
    .miu_spm_req_s3_credit(miu_spm_req_s3_credit),
    .miu_spm_req_s3_stall(miu_spm_req_s3_stall),
    .miu_spm_req_wake(miu_spm_req_wake),
    .spm_miu_rsp_s0_valid(spm_miu_rsp_s0_valid),
    .spm_miu_rsp_s0_payload(spm_miu_rsp_s0_payload),
    .spm_miu_rsp_s0_credit(spm_miu_rsp_s0_credit),
    .spm_miu_rsp_s0_stall(spm_miu_rsp_s0_stall),
    .spm_miu_rsp_s1_valid(spm_miu_rsp_s1_valid),
    .spm_miu_rsp_s1_payload(spm_miu_rsp_s1_payload),
    .spm_miu_rsp_s1_credit(spm_miu_rsp_s1_credit),
    .spm_miu_rsp_s1_stall(spm_miu_rsp_s1_stall),
    .spm_miu_rsp_s2_valid(spm_miu_rsp_s2_valid),
    .spm_miu_rsp_s2_payload(spm_miu_rsp_s2_payload),
    .spm_miu_rsp_s2_credit(spm_miu_rsp_s2_credit),
    .spm_miu_rsp_s2_stall(spm_miu_rsp_s2_stall),
    .spm_miu_rsp_s3_valid(spm_miu_rsp_s3_valid),
    .spm_miu_rsp_s3_payload(spm_miu_rsp_s3_payload),
    .spm_miu_rsp_s3_credit(spm_miu_rsp_s3_credit),
    .spm_miu_rsp_s3_stall(spm_miu_rsp_s3_stall),
    .spm_miu_rsp_wake(spm_miu_rsp_wake)
`ifdef CCV_TRACE
    , .miu_spm_req_s0_tid(miu_spm_req_s0_tid),
      .miu_spm_req_s1_tid(miu_spm_req_s1_tid),
      .miu_spm_req_s2_tid(miu_spm_req_s2_tid),
      .miu_spm_req_s3_tid(miu_spm_req_s3_tid),
      .spm_miu_rsp_s0_tid(spm_miu_rsp_s0_tid),
      .spm_miu_rsp_s1_tid(spm_miu_rsp_s1_tid),
      .spm_miu_rsp_s2_tid(spm_miu_rsp_s2_tid),
      .spm_miu_rsp_s3_tid(spm_miu_rsp_s3_tid)
`endif
  );

  ccv_dcu u_dcu (
    .clk(dcu_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(dcu_sleep_ok),
    .csr_req(csr_reqs[1862 +: 49]),
    .csr_rsp(csr_rsps[1254 +: 33]),
    .csr_credit(csr_credits[38]),
    .miu_dcu_req_s0_valid(miu_dcu_req_s0_valid),
    .miu_dcu_req_s0_payload(miu_dcu_req_s0_payload),
    .miu_dcu_req_s0_credit(miu_dcu_req_s0_credit),
    .miu_dcu_req_s0_stall(miu_dcu_req_s0_stall),
    .miu_dcu_req_s1_valid(miu_dcu_req_s1_valid),
    .miu_dcu_req_s1_payload(miu_dcu_req_s1_payload),
    .miu_dcu_req_s1_credit(miu_dcu_req_s1_credit),
    .miu_dcu_req_s1_stall(miu_dcu_req_s1_stall),
    .miu_dcu_req_s2_valid(miu_dcu_req_s2_valid),
    .miu_dcu_req_s2_payload(miu_dcu_req_s2_payload),
    .miu_dcu_req_s2_credit(miu_dcu_req_s2_credit),
    .miu_dcu_req_s2_stall(miu_dcu_req_s2_stall),
    .miu_dcu_req_s3_valid(miu_dcu_req_s3_valid),
    .miu_dcu_req_s3_payload(miu_dcu_req_s3_payload),
    .miu_dcu_req_s3_credit(miu_dcu_req_s3_credit),
    .miu_dcu_req_s3_stall(miu_dcu_req_s3_stall),
    .miu_dcu_req_wake(miu_dcu_req_wake),
    .dcu_miu_rsp_s0_valid(dcu_miu_rsp_s0_valid),
    .dcu_miu_rsp_s0_payload(dcu_miu_rsp_s0_payload),
    .dcu_miu_rsp_s0_credit(dcu_miu_rsp_s0_credit),
    .dcu_miu_rsp_s0_stall(dcu_miu_rsp_s0_stall),
    .dcu_miu_rsp_s1_valid(dcu_miu_rsp_s1_valid),
    .dcu_miu_rsp_s1_payload(dcu_miu_rsp_s1_payload),
    .dcu_miu_rsp_s1_credit(dcu_miu_rsp_s1_credit),
    .dcu_miu_rsp_s1_stall(dcu_miu_rsp_s1_stall),
    .dcu_miu_rsp_s2_valid(dcu_miu_rsp_s2_valid),
    .dcu_miu_rsp_s2_payload(dcu_miu_rsp_s2_payload),
    .dcu_miu_rsp_s2_credit(dcu_miu_rsp_s2_credit),
    .dcu_miu_rsp_s2_stall(dcu_miu_rsp_s2_stall),
    .dcu_miu_rsp_s3_valid(dcu_miu_rsp_s3_valid),
    .dcu_miu_rsp_s3_payload(dcu_miu_rsp_s3_payload),
    .dcu_miu_rsp_s3_credit(dcu_miu_rsp_s3_credit),
    .dcu_miu_rsp_s3_stall(dcu_miu_rsp_s3_stall),
    .dcu_miu_rsp_wake(dcu_miu_rsp_wake),
    .dcu_mlc_req_valid(dcu_mlc_req_valid),
    .dcu_mlc_req_payload(dcu_mlc_req_payload),
    .dcu_mlc_req_credit(dcu_mlc_req_credit),
    .dcu_mlc_req_stall(dcu_mlc_req_stall),
    .dcu_mlc_req_wake(dcu_mlc_req_wake),
    .mlc_dcu_rsp_valid(mlc_dcu_rsp_valid),
    .mlc_dcu_rsp_payload(mlc_dcu_rsp_payload),
    .mlc_dcu_rsp_credit(mlc_dcu_rsp_credit),
    .mlc_dcu_rsp_stall(mlc_dcu_rsp_stall),
    .mlc_dcu_rsp_wake(mlc_dcu_rsp_wake),
    .mlc_dcu_probe_valid(mlc_dcu_probe_valid),
    .mlc_dcu_probe_payload(mlc_dcu_probe_payload),
    .mlc_dcu_probe_credit(mlc_dcu_probe_credit),
    .mlc_dcu_probe_stall(mlc_dcu_probe_stall),
    .mlc_dcu_probe_wake(mlc_dcu_probe_wake),
    .dcu_mlc_probe_ack_valid(dcu_mlc_probe_ack_valid),
    .dcu_mlc_probe_ack_payload(dcu_mlc_probe_ack_payload),
    .dcu_mlc_probe_ack_credit(dcu_mlc_probe_ack_credit),
    .dcu_mlc_probe_ack_stall(dcu_mlc_probe_ack_stall),
    .dcu_mlc_probe_ack_wake(dcu_mlc_probe_ack_wake)
`ifdef CCV_TRACE
    , .miu_dcu_req_s0_tid(miu_dcu_req_s0_tid),
      .miu_dcu_req_s1_tid(miu_dcu_req_s1_tid),
      .miu_dcu_req_s2_tid(miu_dcu_req_s2_tid),
      .miu_dcu_req_s3_tid(miu_dcu_req_s3_tid),
      .dcu_miu_rsp_s0_tid(dcu_miu_rsp_s0_tid),
      .dcu_miu_rsp_s1_tid(dcu_miu_rsp_s1_tid),
      .dcu_miu_rsp_s2_tid(dcu_miu_rsp_s2_tid),
      .dcu_miu_rsp_s3_tid(dcu_miu_rsp_s3_tid),
      .dcu_mlc_req_tid(dcu_mlc_req_tid),
      .mlc_dcu_rsp_tid(mlc_dcu_rsp_tid),
      .mlc_dcu_probe_tid(mlc_dcu_probe_tid),
      .dcu_mlc_probe_ack_tid(dcu_mlc_probe_ack_tid)
`endif
  );

  ccv_mlc u_mlc (
    .clk(mlc_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(mlc_sleep_ok),
    .csr_req(csr_reqs[1911 +: 49]),
    .csr_rsp(csr_rsps[1287 +: 33]),
    .csr_credit(csr_credits[39]),
    .dcu_mlc_req_valid(dcu_mlc_req_valid),
    .dcu_mlc_req_payload(dcu_mlc_req_payload),
    .dcu_mlc_req_credit(dcu_mlc_req_credit),
    .dcu_mlc_req_stall(dcu_mlc_req_stall),
    .dcu_mlc_req_wake(dcu_mlc_req_wake),
    .mlc_dcu_rsp_valid(mlc_dcu_rsp_valid),
    .mlc_dcu_rsp_payload(mlc_dcu_rsp_payload),
    .mlc_dcu_rsp_credit(mlc_dcu_rsp_credit),
    .mlc_dcu_rsp_stall(mlc_dcu_rsp_stall),
    .mlc_dcu_rsp_wake(mlc_dcu_rsp_wake),
    .mlc_dcu_probe_valid(mlc_dcu_probe_valid),
    .mlc_dcu_probe_payload(mlc_dcu_probe_payload),
    .mlc_dcu_probe_credit(mlc_dcu_probe_credit),
    .mlc_dcu_probe_stall(mlc_dcu_probe_stall),
    .mlc_dcu_probe_wake(mlc_dcu_probe_wake),
    .dcu_mlc_probe_ack_valid(dcu_mlc_probe_ack_valid),
    .dcu_mlc_probe_ack_payload(dcu_mlc_probe_ack_payload),
    .dcu_mlc_probe_ack_credit(dcu_mlc_probe_ack_credit),
    .dcu_mlc_probe_ack_stall(dcu_mlc_probe_ack_stall),
    .dcu_mlc_probe_ack_wake(dcu_mlc_probe_ack_wake),
    .fet_mlc_ifill_valid(fet_mlc_ifill_valid),
    .fet_mlc_ifill_payload(fet_mlc_ifill_payload),
    .fet_mlc_ifill_credit(fet_mlc_ifill_credit),
    .fet_mlc_ifill_stall(fet_mlc_ifill_stall),
    .fet_mlc_ifill_wake(fet_mlc_ifill_wake),
    .mlc_fet_ifill_rsp_valid(mlc_fet_ifill_rsp_valid),
    .mlc_fet_ifill_rsp_payload(mlc_fet_ifill_rsp_payload),
    .mlc_fet_ifill_rsp_credit(mlc_fet_ifill_rsp_credit),
    .mlc_fet_ifill_rsp_stall(mlc_fet_ifill_rsp_stall),
    .mlc_fet_ifill_rsp_wake(mlc_fet_ifill_rsp_wake),
    .mlc_exb_req_valid(mlc_exb_req_valid),
    .mlc_exb_req_payload(mlc_exb_req_payload),
    .mlc_exb_req_credit(mlc_exb_req_credit),
    .mlc_exb_req_stall(mlc_exb_req_stall),
    .mlc_exb_req_wake(mlc_exb_req_wake),
    .exb_mlc_rsp_valid(exb_mlc_rsp_valid),
    .exb_mlc_rsp_payload(exb_mlc_rsp_payload),
    .exb_mlc_rsp_credit(exb_mlc_rsp_credit),
    .exb_mlc_rsp_stall(exb_mlc_rsp_stall),
    .exb_mlc_rsp_wake(exb_mlc_rsp_wake)
`ifdef CCV_TRACE
    , .dcu_mlc_req_tid(dcu_mlc_req_tid),
      .mlc_dcu_rsp_tid(mlc_dcu_rsp_tid),
      .mlc_dcu_probe_tid(mlc_dcu_probe_tid),
      .dcu_mlc_probe_ack_tid(dcu_mlc_probe_ack_tid),
      .fet_mlc_ifill_tid(fet_mlc_ifill_tid),
      .mlc_fet_ifill_rsp_tid(mlc_fet_ifill_rsp_tid),
      .mlc_exb_req_tid(mlc_exb_req_tid),
      .exb_mlc_rsp_tid(exb_mlc_rsp_tid)
`endif
  );

  ccv_rau u_rau (
    .clk(rau_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_acks(kill_ack),
    .kill_ack_epochs(kill_ack_epoch),
    .sleep_ok(rau_sleep_ok),
    .csr_req(csr_reqs[1960 +: 49]),
    .csr_rsp(csr_rsps[1320 +: 33]),
    .csr_credit(csr_credits[40]),
    .rau_fet_launch_valid(rau_fet_launch_valid),
    .rau_fet_launch_payload(rau_fet_launch_payload),
    .rau_fet_launch_credit(rau_fet_launch_credit),
    .rau_fet_launch_stall(rau_fet_launch_stall),
    .rau_fet_launch_wake(rau_fet_launch_wake),
    .rau_ooe_alloc_valid(rau_ooe_alloc_valid),
    .rau_ooe_alloc_payload(rau_ooe_alloc_payload),
    .rau_ooe_alloc_credit(rau_ooe_alloc_credit),
    .rau_ooe_alloc_stall(rau_ooe_alloc_stall),
    .rau_ooe_alloc_wake(rau_ooe_alloc_wake),
    .ooe_rau_status_valid(ooe_rau_status_valid),
    .ooe_rau_status_payload(ooe_rau_status_payload),
    .ooe_rau_status_credit(ooe_rau_status_credit),
    .ooe_rau_status_stall(ooe_rau_status_stall),
    .ooe_rau_status_wake(ooe_rau_status_wake),
    .rau_ooe_demote_valid(rau_ooe_demote_valid),
    .rau_ooe_demote_payload(rau_ooe_demote_payload),
    .rau_ooe_demote_credit(rau_ooe_demote_credit),
    .rau_ooe_demote_stall(rau_ooe_demote_stall),
    .rau_ooe_demote_wake(rau_ooe_demote_wake),
    .ooe_rau_drained_valid(ooe_rau_drained_valid),
    .ooe_rau_drained_payload(ooe_rau_drained_payload),
    .ooe_rau_drained_credit(ooe_rau_drained_credit),
    .ooe_rau_drained_stall(ooe_rau_drained_stall),
    .ooe_rau_drained_wake(ooe_rau_drained_wake),
    .rau_rcu_mig_valid(rau_rcu_mig_valid),
    .rau_rcu_mig_payload(rau_rcu_mig_payload),
    .rau_rcu_mig_credit(rau_rcu_mig_credit),
    .rau_rcu_mig_stall(rau_rcu_mig_stall),
    .rau_rcu_mig_wake(rau_rcu_mig_wake),
    .rau_fet_mig_valid(rau_fet_mig_valid),
    .rau_fet_mig_payload(rau_fet_mig_payload),
    .rau_fet_mig_credit(rau_fet_mig_credit),
    .rau_fet_mig_stall(rau_fet_mig_stall),
    .rau_fet_mig_wake(rau_fet_mig_wake),
    .pca_rau_mig_done_valid(pca_rau_mig_done_valid),
    .pca_rau_mig_done_payload(pca_rau_mig_done_payload),
    .pca_rau_mig_done_credit(pca_rau_mig_done_credit),
    .pca_rau_mig_done_stall(pca_rau_mig_done_stall),
    .pca_rau_mig_done_wake(pca_rau_mig_done_wake),
    .rau_miu_cta_valid(rau_miu_cta_valid),
    .rau_miu_cta_payload(rau_miu_cta_payload),
    .rau_miu_cta_credit(rau_miu_cta_credit),
    .rau_miu_cta_stall(rau_miu_cta_stall),
    .rau_miu_cta_wake(rau_miu_cta_wake),
    .rau_syu_alloc_valid(rau_syu_alloc_valid),
    .rau_syu_alloc_payload(rau_syu_alloc_payload),
    .rau_syu_alloc_credit(rau_syu_alloc_credit),
    .rau_syu_alloc_stall(rau_syu_alloc_stall),
    .rau_syu_alloc_wake(rau_syu_alloc_wake),
    .cru_rau_cfg_valid(cru_rau_cfg_valid),
    .cru_rau_cfg_payload(cru_rau_cfg_payload),
    .cru_rau_cfg_credit(cru_rau_cfg_credit),
    .cru_rau_cfg_stall(cru_rau_cfg_stall),
    .cru_rau_cfg_wake(cru_rau_cfg_wake)
`ifdef CCV_TRACE
    , .rau_fet_launch_tid(rau_fet_launch_tid),
      .rau_ooe_alloc_tid(rau_ooe_alloc_tid),
      .ooe_rau_status_tid(ooe_rau_status_tid),
      .rau_ooe_demote_tid(rau_ooe_demote_tid),
      .ooe_rau_drained_tid(ooe_rau_drained_tid),
      .rau_rcu_mig_tid(rau_rcu_mig_tid),
      .rau_fet_mig_tid(rau_fet_mig_tid),
      .pca_rau_mig_done_tid(pca_rau_mig_done_tid),
      .rau_miu_cta_tid(rau_miu_cta_tid),
      .rau_syu_alloc_tid(rau_syu_alloc_tid),
      .cru_rau_cfg_tid(cru_rau_cfg_tid)
`endif
  );

  ccv_syu u_syu (
    .clk(syu_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[6]),
    .kill_ack_epoch(kill_ack_epoch[12 +: 2]),
    .sleep_ok(syu_sleep_ok),
    .csr_req(csr_reqs[2009 +: 49]),
    .csr_rsp(csr_rsps[1353 +: 33]),
    .csr_credit(csr_credits[41]),
    .ooe_syu_bar_valid(ooe_syu_bar_valid),
    .ooe_syu_bar_payload(ooe_syu_bar_payload),
    .ooe_syu_bar_credit(ooe_syu_bar_credit),
    .ooe_syu_bar_stall(ooe_syu_bar_stall),
    .ooe_syu_bar_wake(ooe_syu_bar_wake),
    .syu_ooe_rel_valid(syu_ooe_rel_valid),
    .syu_ooe_rel_payload(syu_ooe_rel_payload),
    .syu_ooe_rel_credit(syu_ooe_rel_credit),
    .syu_ooe_rel_stall(syu_ooe_rel_stall),
    .syu_ooe_rel_wake(syu_ooe_rel_wake),
    .rau_syu_alloc_valid(rau_syu_alloc_valid),
    .rau_syu_alloc_payload(rau_syu_alloc_payload),
    .rau_syu_alloc_credit(rau_syu_alloc_credit),
    .rau_syu_alloc_stall(rau_syu_alloc_stall),
    .rau_syu_alloc_wake(rau_syu_alloc_wake)
`ifdef CCV_TRACE
    , .ooe_syu_bar_tid(ooe_syu_bar_tid),
      .syu_ooe_rel_tid(syu_ooe_rel_tid),
      .rau_syu_alloc_tid(rau_syu_alloc_tid)
`endif
  );

  ccv_pca u_pca (
    .clk(pca_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack[7]),
    .kill_ack_epoch(kill_ack_epoch[14 +: 2]),
    .sleep_ok(pca_sleep_ok),
    .csr_req(csr_reqs[2058 +: 49]),
    .csr_rsp(csr_rsps[1386 +: 33]),
    .csr_credit(csr_credits[42]),
    .rcu_pca_mig_valid(rcu_pca_mig_valid),
    .rcu_pca_mig_payload(rcu_pca_mig_payload),
    .rcu_pca_mig_credit(rcu_pca_mig_credit),
    .rcu_pca_mig_stall(rcu_pca_mig_stall),
    .rcu_pca_mig_wake(rcu_pca_mig_wake),
    .pca_rcu_mig_valid(pca_rcu_mig_valid),
    .pca_rcu_mig_payload(pca_rcu_mig_payload),
    .pca_rcu_mig_credit(pca_rcu_mig_credit),
    .pca_rcu_mig_stall(pca_rcu_mig_stall),
    .pca_rcu_mig_wake(pca_rcu_mig_wake),
    .fet_pca_mig_valid(fet_pca_mig_valid),
    .fet_pca_mig_payload(fet_pca_mig_payload),
    .fet_pca_mig_credit(fet_pca_mig_credit),
    .fet_pca_mig_stall(fet_pca_mig_stall),
    .fet_pca_mig_wake(fet_pca_mig_wake),
    .pca_fet_mig_valid(pca_fet_mig_valid),
    .pca_fet_mig_payload(pca_fet_mig_payload),
    .pca_fet_mig_credit(pca_fet_mig_credit),
    .pca_fet_mig_stall(pca_fet_mig_stall),
    .pca_fet_mig_wake(pca_fet_mig_wake),
    .pca_rau_mig_done_valid(pca_rau_mig_done_valid),
    .pca_rau_mig_done_payload(pca_rau_mig_done_payload),
    .pca_rau_mig_done_credit(pca_rau_mig_done_credit),
    .pca_rau_mig_done_stall(pca_rau_mig_done_stall),
    .pca_rau_mig_done_wake(pca_rau_mig_done_wake)
`ifdef CCV_TRACE
    , .rcu_pca_mig_tid(rcu_pca_mig_tid),
      .pca_rcu_mig_tid(pca_rcu_mig_tid),
      .fet_pca_mig_tid(fet_pca_mig_tid),
      .pca_fet_mig_tid(pca_fet_mig_tid),
      .pca_rau_mig_done_tid(pca_rau_mig_done_tid)
`endif
  );

  ccv_cru u_cru (
    .clk(cru_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(cru_sleep_ok),
    .csr_req(csr_req),
    .csr_reqs(csr_reqs),
    .csr_rsp(csr_rsp),
    .csr_rsps(csr_rsps),
    .csr_credit(csr_credit),
    .csr_credits(csr_credits),
    .ooe_cru_fault_valid(ooe_cru_fault_valid),
    .ooe_cru_fault_payload(ooe_cru_fault_payload),
    .ooe_cru_fault_credit(ooe_cru_fault_credit),
    .ooe_cru_fault_stall(ooe_cru_fault_stall),
    .ooe_cru_fault_wake(ooe_cru_fault_wake),
    .cru_rau_cfg_valid(cru_rau_cfg_valid),
    .cru_rau_cfg_payload(cru_rau_cfg_payload),
    .cru_rau_cfg_credit(cru_rau_cfg_credit),
    .cru_rau_cfg_stall(cru_rau_cfg_stall),
    .cru_rau_cfg_wake(cru_rau_cfg_wake)
`ifdef CCV_TRACE
    , .ooe_cru_fault_tid(ooe_cru_fault_tid),
      .cru_rau_cfg_tid(cru_rau_cfg_tid)
`endif
  );

  ccv_exb u_exb (
    .clk(exb_core_clk),
    .clk_free(core_clk),
    .rst_n(rst_n),
    .sleep_ok(exb_sleep_ok),
    .csr_req(csr_reqs[2156 +: 49]),
    .csr_rsp(csr_rsps[1452 +: 33]),
    .csr_credit(csr_credits[44]),
    .mlc_exb_req_valid(mlc_exb_req_valid),
    .mlc_exb_req_payload(mlc_exb_req_payload),
    .mlc_exb_req_credit(mlc_exb_req_credit),
    .mlc_exb_req_stall(mlc_exb_req_stall),
    .mlc_exb_req_wake(mlc_exb_req_wake),
    .exb_mlc_rsp_valid(exb_mlc_rsp_valid),
    .exb_mlc_rsp_payload(exb_mlc_rsp_payload),
    .exb_mlc_rsp_credit(exb_mlc_rsp_credit),
    .exb_mlc_rsp_stall(exb_mlc_rsp_stall),
    .exb_mlc_rsp_wake(exb_mlc_rsp_wake),
    .exb_ext_out_valid(exb_ext_out_valid),
    .exb_ext_out_payload(exb_ext_out_payload),
    .exb_ext_out_credit(exb_ext_out_credit),
    .exb_ext_out_stall(exb_ext_out_stall),
    .exb_ext_out_wake(exb_ext_out_wake),
    .ext_exb_in_valid(ext_exb_in_valid),
    .ext_exb_in_payload(ext_exb_in_payload),
    .ext_exb_in_credit(ext_exb_in_credit),
    .ext_exb_in_stall(ext_exb_in_stall),
    .ext_exb_in_wake(ext_exb_in_wake)
`ifdef CCV_TRACE
    , .mlc_exb_req_tid(mlc_exb_req_tid),
      .exb_mlc_rsp_tid(exb_mlc_rsp_tid),
      .exb_ext_out_tid(exb_ext_out_tid),
      .ext_exb_in_tid(ext_exb_in_tid)
`endif
  );

`ifdef CCV_CHECK
  // The SAME checker bank the C++ skeleton Verilates, on the real
  // nets. Absent unless CCV_CHECK is defined, so synthesis never
  // sees a checker.
  ccv_skel_checkers u_checkers (
    .clk(core_clk), .rst_n(rst_n), .force_atomic(1'b0), .pair_enable(1'b1),
    .valid({ext_exb_in_valid, cru_rau_cfg_valid, ooe_cru_fault_valid, rau_syu_alloc_valid, syu_ooe_rel_valid, ooe_syu_bar_valid, rau_miu_cta_valid, pca_rau_mig_done_valid, rau_fet_mig_valid, pca_fet_mig_valid, fet_pca_mig_valid, pca_rcu_mig_valid, rcu_pca_mig_valid, rau_rcu_mig_valid, ooe_rau_drained_valid, rau_ooe_demote_valid, ooe_rau_status_valid, rau_ooe_alloc_valid, rau_fet_launch_valid, exb_ext_out_valid, exb_mlc_rsp_valid, mlc_exb_req_valid, fet_miu_itlb_req_valid, miu_fet_itlb_valid, mlc_fet_ifill_rsp_valid, fet_mlc_ifill_valid, dcu_mlc_probe_ack_valid, mlc_dcu_probe_valid, mlc_dcu_rsp_valid, dcu_mlc_req_valid, dcu_miu_rsp_s3_valid, dcu_miu_rsp_s2_valid, dcu_miu_rsp_s1_valid, dcu_miu_rsp_s0_valid, miu_dcu_req_s3_valid, miu_dcu_req_s2_valid, miu_dcu_req_s1_valid, miu_dcu_req_s0_valid, spm_miu_rsp_s3_valid, spm_miu_rsp_s2_valid, spm_miu_rsp_s1_valid, spm_miu_rsp_s0_valid, miu_spm_req_s3_valid, miu_spm_req_s2_valid, miu_spm_req_s1_valid, miu_spm_req_s0_valid, ooe_fet_redirect_valid, ooe_miu_retire_s3_valid, ooe_miu_retire_s2_valid, ooe_miu_retire_s1_valid, ooe_miu_retire_s0_valid, miu_ooe_cmpl_s3_valid, miu_ooe_cmpl_s2_valid, miu_ooe_cmpl_s1_valid, miu_ooe_cmpl_s0_valid, ooe_miu_memop_s3_valid, ooe_miu_memop_s2_valid, ooe_miu_memop_s1_valid, ooe_miu_memop_s0_valid, miu_rcu_data_s3_valid, miu_rcu_data_s2_valid, miu_rcu_data_s1_valid, miu_rcu_data_s0_valid, rcu_miu_addr_s3_valid, rcu_miu_addr_s2_valid, rcu_miu_addr_s1_valid, rcu_miu_addr_s0_valid, rcu_ooe_done_s3_valid, rcu_ooe_done_s2_valid, rcu_ooe_done_s1_valid, rcu_ooe_done_s0_valid, lane_rcu_res_c31_s3_valid, lane_rcu_res_c31_s2_valid, lane_rcu_res_c31_s1_valid, lane_rcu_res_c31_s0_valid, lane_rcu_res_c30_s3_valid, lane_rcu_res_c30_s2_valid, lane_rcu_res_c30_s1_valid, lane_rcu_res_c30_s0_valid, lane_rcu_res_c29_s3_valid, lane_rcu_res_c29_s2_valid, lane_rcu_res_c29_s1_valid, lane_rcu_res_c29_s0_valid, lane_rcu_res_c28_s3_valid, lane_rcu_res_c28_s2_valid, lane_rcu_res_c28_s1_valid, lane_rcu_res_c28_s0_valid, lane_rcu_res_c27_s3_valid, lane_rcu_res_c27_s2_valid, lane_rcu_res_c27_s1_valid, lane_rcu_res_c27_s0_valid, lane_rcu_res_c26_s3_valid, lane_rcu_res_c26_s2_valid, lane_rcu_res_c26_s1_valid, lane_rcu_res_c26_s0_valid, lane_rcu_res_c25_s3_valid, lane_rcu_res_c25_s2_valid, lane_rcu_res_c25_s1_valid, lane_rcu_res_c25_s0_valid, lane_rcu_res_c24_s3_valid, lane_rcu_res_c24_s2_valid, lane_rcu_res_c24_s1_valid, lane_rcu_res_c24_s0_valid, lane_rcu_res_c23_s3_valid, lane_rcu_res_c23_s2_valid, lane_rcu_res_c23_s1_valid, lane_rcu_res_c23_s0_valid, lane_rcu_res_c22_s3_valid, lane_rcu_res_c22_s2_valid, lane_rcu_res_c22_s1_valid, lane_rcu_res_c22_s0_valid, lane_rcu_res_c21_s3_valid, lane_rcu_res_c21_s2_valid, lane_rcu_res_c21_s1_valid, lane_rcu_res_c21_s0_valid, lane_rcu_res_c20_s3_valid, lane_rcu_res_c20_s2_valid, lane_rcu_res_c20_s1_valid, lane_rcu_res_c20_s0_valid, lane_rcu_res_c19_s3_valid, lane_rcu_res_c19_s2_valid, lane_rcu_res_c19_s1_valid, lane_rcu_res_c19_s0_valid, lane_rcu_res_c18_s3_valid, lane_rcu_res_c18_s2_valid, lane_rcu_res_c18_s1_valid, lane_rcu_res_c18_s0_valid, lane_rcu_res_c17_s3_valid, lane_rcu_res_c17_s2_valid, lane_rcu_res_c17_s1_valid, lane_rcu_res_c17_s0_valid, lane_rcu_res_c16_s3_valid, lane_rcu_res_c16_s2_valid, lane_rcu_res_c16_s1_valid, lane_rcu_res_c16_s0_valid, lane_rcu_res_c15_s3_valid, lane_rcu_res_c15_s2_valid, lane_rcu_res_c15_s1_valid, lane_rcu_res_c15_s0_valid, lane_rcu_res_c14_s3_valid, lane_rcu_res_c14_s2_valid, lane_rcu_res_c14_s1_valid, lane_rcu_res_c14_s0_valid, lane_rcu_res_c13_s3_valid, lane_rcu_res_c13_s2_valid, lane_rcu_res_c13_s1_valid, lane_rcu_res_c13_s0_valid, lane_rcu_res_c12_s3_valid, lane_rcu_res_c12_s2_valid, lane_rcu_res_c12_s1_valid, lane_rcu_res_c12_s0_valid, lane_rcu_res_c11_s3_valid, lane_rcu_res_c11_s2_valid, lane_rcu_res_c11_s1_valid, lane_rcu_res_c11_s0_valid, lane_rcu_res_c10_s3_valid, lane_rcu_res_c10_s2_valid, lane_rcu_res_c10_s1_valid, lane_rcu_res_c10_s0_valid, lane_rcu_res_c09_s3_valid, lane_rcu_res_c09_s2_valid, lane_rcu_res_c09_s1_valid, lane_rcu_res_c09_s0_valid, lane_rcu_res_c08_s3_valid, lane_rcu_res_c08_s2_valid, lane_rcu_res_c08_s1_valid, lane_rcu_res_c08_s0_valid, lane_rcu_res_c07_s3_valid, lane_rcu_res_c07_s2_valid, lane_rcu_res_c07_s1_valid, lane_rcu_res_c07_s0_valid, lane_rcu_res_c06_s3_valid, lane_rcu_res_c06_s2_valid, lane_rcu_res_c06_s1_valid, lane_rcu_res_c06_s0_valid, lane_rcu_res_c05_s3_valid, lane_rcu_res_c05_s2_valid, lane_rcu_res_c05_s1_valid, lane_rcu_res_c05_s0_valid, lane_rcu_res_c04_s3_valid, lane_rcu_res_c04_s2_valid, lane_rcu_res_c04_s1_valid, lane_rcu_res_c04_s0_valid, lane_rcu_res_c03_s3_valid, lane_rcu_res_c03_s2_valid, lane_rcu_res_c03_s1_valid, lane_rcu_res_c03_s0_valid, lane_rcu_res_c02_s3_valid, lane_rcu_res_c02_s2_valid, lane_rcu_res_c02_s1_valid, lane_rcu_res_c02_s0_valid, lane_rcu_res_c01_s3_valid, lane_rcu_res_c01_s2_valid, lane_rcu_res_c01_s1_valid, lane_rcu_res_c01_s0_valid, lane_rcu_res_c00_s3_valid, lane_rcu_res_c00_s2_valid, lane_rcu_res_c00_s1_valid, lane_rcu_res_c00_s0_valid, rcu_lane_ops_c31_s3_valid, rcu_lane_ops_c31_s2_valid, rcu_lane_ops_c31_s1_valid, rcu_lane_ops_c31_s0_valid, rcu_lane_ops_c30_s3_valid, rcu_lane_ops_c30_s2_valid, rcu_lane_ops_c30_s1_valid, rcu_lane_ops_c30_s0_valid, rcu_lane_ops_c29_s3_valid, rcu_lane_ops_c29_s2_valid, rcu_lane_ops_c29_s1_valid, rcu_lane_ops_c29_s0_valid, rcu_lane_ops_c28_s3_valid, rcu_lane_ops_c28_s2_valid, rcu_lane_ops_c28_s1_valid, rcu_lane_ops_c28_s0_valid, rcu_lane_ops_c27_s3_valid, rcu_lane_ops_c27_s2_valid, rcu_lane_ops_c27_s1_valid, rcu_lane_ops_c27_s0_valid, rcu_lane_ops_c26_s3_valid, rcu_lane_ops_c26_s2_valid, rcu_lane_ops_c26_s1_valid, rcu_lane_ops_c26_s0_valid, rcu_lane_ops_c25_s3_valid, rcu_lane_ops_c25_s2_valid, rcu_lane_ops_c25_s1_valid, rcu_lane_ops_c25_s0_valid, rcu_lane_ops_c24_s3_valid, rcu_lane_ops_c24_s2_valid, rcu_lane_ops_c24_s1_valid, rcu_lane_ops_c24_s0_valid, rcu_lane_ops_c23_s3_valid, rcu_lane_ops_c23_s2_valid, rcu_lane_ops_c23_s1_valid, rcu_lane_ops_c23_s0_valid, rcu_lane_ops_c22_s3_valid, rcu_lane_ops_c22_s2_valid, rcu_lane_ops_c22_s1_valid, rcu_lane_ops_c22_s0_valid, rcu_lane_ops_c21_s3_valid, rcu_lane_ops_c21_s2_valid, rcu_lane_ops_c21_s1_valid, rcu_lane_ops_c21_s0_valid, rcu_lane_ops_c20_s3_valid, rcu_lane_ops_c20_s2_valid, rcu_lane_ops_c20_s1_valid, rcu_lane_ops_c20_s0_valid, rcu_lane_ops_c19_s3_valid, rcu_lane_ops_c19_s2_valid, rcu_lane_ops_c19_s1_valid, rcu_lane_ops_c19_s0_valid, rcu_lane_ops_c18_s3_valid, rcu_lane_ops_c18_s2_valid, rcu_lane_ops_c18_s1_valid, rcu_lane_ops_c18_s0_valid, rcu_lane_ops_c17_s3_valid, rcu_lane_ops_c17_s2_valid, rcu_lane_ops_c17_s1_valid, rcu_lane_ops_c17_s0_valid, rcu_lane_ops_c16_s3_valid, rcu_lane_ops_c16_s2_valid, rcu_lane_ops_c16_s1_valid, rcu_lane_ops_c16_s0_valid, rcu_lane_ops_c15_s3_valid, rcu_lane_ops_c15_s2_valid, rcu_lane_ops_c15_s1_valid, rcu_lane_ops_c15_s0_valid, rcu_lane_ops_c14_s3_valid, rcu_lane_ops_c14_s2_valid, rcu_lane_ops_c14_s1_valid, rcu_lane_ops_c14_s0_valid, rcu_lane_ops_c13_s3_valid, rcu_lane_ops_c13_s2_valid, rcu_lane_ops_c13_s1_valid, rcu_lane_ops_c13_s0_valid, rcu_lane_ops_c12_s3_valid, rcu_lane_ops_c12_s2_valid, rcu_lane_ops_c12_s1_valid, rcu_lane_ops_c12_s0_valid, rcu_lane_ops_c11_s3_valid, rcu_lane_ops_c11_s2_valid, rcu_lane_ops_c11_s1_valid, rcu_lane_ops_c11_s0_valid, rcu_lane_ops_c10_s3_valid, rcu_lane_ops_c10_s2_valid, rcu_lane_ops_c10_s1_valid, rcu_lane_ops_c10_s0_valid, rcu_lane_ops_c09_s3_valid, rcu_lane_ops_c09_s2_valid, rcu_lane_ops_c09_s1_valid, rcu_lane_ops_c09_s0_valid, rcu_lane_ops_c08_s3_valid, rcu_lane_ops_c08_s2_valid, rcu_lane_ops_c08_s1_valid, rcu_lane_ops_c08_s0_valid, rcu_lane_ops_c07_s3_valid, rcu_lane_ops_c07_s2_valid, rcu_lane_ops_c07_s1_valid, rcu_lane_ops_c07_s0_valid, rcu_lane_ops_c06_s3_valid, rcu_lane_ops_c06_s2_valid, rcu_lane_ops_c06_s1_valid, rcu_lane_ops_c06_s0_valid, rcu_lane_ops_c05_s3_valid, rcu_lane_ops_c05_s2_valid, rcu_lane_ops_c05_s1_valid, rcu_lane_ops_c05_s0_valid, rcu_lane_ops_c04_s3_valid, rcu_lane_ops_c04_s2_valid, rcu_lane_ops_c04_s1_valid, rcu_lane_ops_c04_s0_valid, rcu_lane_ops_c03_s3_valid, rcu_lane_ops_c03_s2_valid, rcu_lane_ops_c03_s1_valid, rcu_lane_ops_c03_s0_valid, rcu_lane_ops_c02_s3_valid, rcu_lane_ops_c02_s2_valid, rcu_lane_ops_c02_s1_valid, rcu_lane_ops_c02_s0_valid, rcu_lane_ops_c01_s3_valid, rcu_lane_ops_c01_s2_valid, rcu_lane_ops_c01_s1_valid, rcu_lane_ops_c01_s0_valid, rcu_lane_ops_c00_s3_valid, rcu_lane_ops_c00_s2_valid, rcu_lane_ops_c00_s1_valid, rcu_lane_ops_c00_s0_valid, ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_valid, ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_valid, dec_ooe_uop_s5_valid, dec_ooe_uop_s4_valid, dec_ooe_uop_s3_valid, dec_ooe_uop_s2_valid, dec_ooe_uop_s1_valid, dec_ooe_uop_s0_valid, fet_dec_instr_s7_valid, fet_dec_instr_s6_valid, fet_dec_instr_s5_valid, fet_dec_instr_s4_valid, fet_dec_instr_s3_valid, fet_dec_instr_s2_valid, fet_dec_instr_s1_valid, fet_dec_instr_s0_valid}),
    .credit({ext_exb_in_credit, cru_rau_cfg_credit, ooe_cru_fault_credit, rau_syu_alloc_credit, syu_ooe_rel_credit, ooe_syu_bar_credit, rau_miu_cta_credit, pca_rau_mig_done_credit, rau_fet_mig_credit, pca_fet_mig_credit, fet_pca_mig_credit, pca_rcu_mig_credit, rcu_pca_mig_credit, rau_rcu_mig_credit, ooe_rau_drained_credit, rau_ooe_demote_credit, ooe_rau_status_credit, rau_ooe_alloc_credit, rau_fet_launch_credit, exb_ext_out_credit, exb_mlc_rsp_credit, mlc_exb_req_credit, fet_miu_itlb_req_credit, miu_fet_itlb_credit, mlc_fet_ifill_rsp_credit, fet_mlc_ifill_credit, dcu_mlc_probe_ack_credit, mlc_dcu_probe_credit, mlc_dcu_rsp_credit, dcu_mlc_req_credit, dcu_miu_rsp_s3_credit, dcu_miu_rsp_s2_credit, dcu_miu_rsp_s1_credit, dcu_miu_rsp_s0_credit, miu_dcu_req_s3_credit, miu_dcu_req_s2_credit, miu_dcu_req_s1_credit, miu_dcu_req_s0_credit, spm_miu_rsp_s3_credit, spm_miu_rsp_s2_credit, spm_miu_rsp_s1_credit, spm_miu_rsp_s0_credit, miu_spm_req_s3_credit, miu_spm_req_s2_credit, miu_spm_req_s1_credit, miu_spm_req_s0_credit, ooe_fet_redirect_credit, ooe_miu_retire_s3_credit, ooe_miu_retire_s2_credit, ooe_miu_retire_s1_credit, ooe_miu_retire_s0_credit, miu_ooe_cmpl_s3_credit, miu_ooe_cmpl_s2_credit, miu_ooe_cmpl_s1_credit, miu_ooe_cmpl_s0_credit, ooe_miu_memop_s3_credit, ooe_miu_memop_s2_credit, ooe_miu_memop_s1_credit, ooe_miu_memop_s0_credit, miu_rcu_data_s3_credit, miu_rcu_data_s2_credit, miu_rcu_data_s1_credit, miu_rcu_data_s0_credit, rcu_miu_addr_s3_credit, rcu_miu_addr_s2_credit, rcu_miu_addr_s1_credit, rcu_miu_addr_s0_credit, rcu_ooe_done_s3_credit, rcu_ooe_done_s2_credit, rcu_ooe_done_s1_credit, rcu_ooe_done_s0_credit, lane_rcu_res_c31_s3_credit, lane_rcu_res_c31_s2_credit, lane_rcu_res_c31_s1_credit, lane_rcu_res_c31_s0_credit, lane_rcu_res_c30_s3_credit, lane_rcu_res_c30_s2_credit, lane_rcu_res_c30_s1_credit, lane_rcu_res_c30_s0_credit, lane_rcu_res_c29_s3_credit, lane_rcu_res_c29_s2_credit, lane_rcu_res_c29_s1_credit, lane_rcu_res_c29_s0_credit, lane_rcu_res_c28_s3_credit, lane_rcu_res_c28_s2_credit, lane_rcu_res_c28_s1_credit, lane_rcu_res_c28_s0_credit, lane_rcu_res_c27_s3_credit, lane_rcu_res_c27_s2_credit, lane_rcu_res_c27_s1_credit, lane_rcu_res_c27_s0_credit, lane_rcu_res_c26_s3_credit, lane_rcu_res_c26_s2_credit, lane_rcu_res_c26_s1_credit, lane_rcu_res_c26_s0_credit, lane_rcu_res_c25_s3_credit, lane_rcu_res_c25_s2_credit, lane_rcu_res_c25_s1_credit, lane_rcu_res_c25_s0_credit, lane_rcu_res_c24_s3_credit, lane_rcu_res_c24_s2_credit, lane_rcu_res_c24_s1_credit, lane_rcu_res_c24_s0_credit, lane_rcu_res_c23_s3_credit, lane_rcu_res_c23_s2_credit, lane_rcu_res_c23_s1_credit, lane_rcu_res_c23_s0_credit, lane_rcu_res_c22_s3_credit, lane_rcu_res_c22_s2_credit, lane_rcu_res_c22_s1_credit, lane_rcu_res_c22_s0_credit, lane_rcu_res_c21_s3_credit, lane_rcu_res_c21_s2_credit, lane_rcu_res_c21_s1_credit, lane_rcu_res_c21_s0_credit, lane_rcu_res_c20_s3_credit, lane_rcu_res_c20_s2_credit, lane_rcu_res_c20_s1_credit, lane_rcu_res_c20_s0_credit, lane_rcu_res_c19_s3_credit, lane_rcu_res_c19_s2_credit, lane_rcu_res_c19_s1_credit, lane_rcu_res_c19_s0_credit, lane_rcu_res_c18_s3_credit, lane_rcu_res_c18_s2_credit, lane_rcu_res_c18_s1_credit, lane_rcu_res_c18_s0_credit, lane_rcu_res_c17_s3_credit, lane_rcu_res_c17_s2_credit, lane_rcu_res_c17_s1_credit, lane_rcu_res_c17_s0_credit, lane_rcu_res_c16_s3_credit, lane_rcu_res_c16_s2_credit, lane_rcu_res_c16_s1_credit, lane_rcu_res_c16_s0_credit, lane_rcu_res_c15_s3_credit, lane_rcu_res_c15_s2_credit, lane_rcu_res_c15_s1_credit, lane_rcu_res_c15_s0_credit, lane_rcu_res_c14_s3_credit, lane_rcu_res_c14_s2_credit, lane_rcu_res_c14_s1_credit, lane_rcu_res_c14_s0_credit, lane_rcu_res_c13_s3_credit, lane_rcu_res_c13_s2_credit, lane_rcu_res_c13_s1_credit, lane_rcu_res_c13_s0_credit, lane_rcu_res_c12_s3_credit, lane_rcu_res_c12_s2_credit, lane_rcu_res_c12_s1_credit, lane_rcu_res_c12_s0_credit, lane_rcu_res_c11_s3_credit, lane_rcu_res_c11_s2_credit, lane_rcu_res_c11_s1_credit, lane_rcu_res_c11_s0_credit, lane_rcu_res_c10_s3_credit, lane_rcu_res_c10_s2_credit, lane_rcu_res_c10_s1_credit, lane_rcu_res_c10_s0_credit, lane_rcu_res_c09_s3_credit, lane_rcu_res_c09_s2_credit, lane_rcu_res_c09_s1_credit, lane_rcu_res_c09_s0_credit, lane_rcu_res_c08_s3_credit, lane_rcu_res_c08_s2_credit, lane_rcu_res_c08_s1_credit, lane_rcu_res_c08_s0_credit, lane_rcu_res_c07_s3_credit, lane_rcu_res_c07_s2_credit, lane_rcu_res_c07_s1_credit, lane_rcu_res_c07_s0_credit, lane_rcu_res_c06_s3_credit, lane_rcu_res_c06_s2_credit, lane_rcu_res_c06_s1_credit, lane_rcu_res_c06_s0_credit, lane_rcu_res_c05_s3_credit, lane_rcu_res_c05_s2_credit, lane_rcu_res_c05_s1_credit, lane_rcu_res_c05_s0_credit, lane_rcu_res_c04_s3_credit, lane_rcu_res_c04_s2_credit, lane_rcu_res_c04_s1_credit, lane_rcu_res_c04_s0_credit, lane_rcu_res_c03_s3_credit, lane_rcu_res_c03_s2_credit, lane_rcu_res_c03_s1_credit, lane_rcu_res_c03_s0_credit, lane_rcu_res_c02_s3_credit, lane_rcu_res_c02_s2_credit, lane_rcu_res_c02_s1_credit, lane_rcu_res_c02_s0_credit, lane_rcu_res_c01_s3_credit, lane_rcu_res_c01_s2_credit, lane_rcu_res_c01_s1_credit, lane_rcu_res_c01_s0_credit, lane_rcu_res_c00_s3_credit, lane_rcu_res_c00_s2_credit, lane_rcu_res_c00_s1_credit, lane_rcu_res_c00_s0_credit, rcu_lane_ops_c31_s3_credit, rcu_lane_ops_c31_s2_credit, rcu_lane_ops_c31_s1_credit, rcu_lane_ops_c31_s0_credit, rcu_lane_ops_c30_s3_credit, rcu_lane_ops_c30_s2_credit, rcu_lane_ops_c30_s1_credit, rcu_lane_ops_c30_s0_credit, rcu_lane_ops_c29_s3_credit, rcu_lane_ops_c29_s2_credit, rcu_lane_ops_c29_s1_credit, rcu_lane_ops_c29_s0_credit, rcu_lane_ops_c28_s3_credit, rcu_lane_ops_c28_s2_credit, rcu_lane_ops_c28_s1_credit, rcu_lane_ops_c28_s0_credit, rcu_lane_ops_c27_s3_credit, rcu_lane_ops_c27_s2_credit, rcu_lane_ops_c27_s1_credit, rcu_lane_ops_c27_s0_credit, rcu_lane_ops_c26_s3_credit, rcu_lane_ops_c26_s2_credit, rcu_lane_ops_c26_s1_credit, rcu_lane_ops_c26_s0_credit, rcu_lane_ops_c25_s3_credit, rcu_lane_ops_c25_s2_credit, rcu_lane_ops_c25_s1_credit, rcu_lane_ops_c25_s0_credit, rcu_lane_ops_c24_s3_credit, rcu_lane_ops_c24_s2_credit, rcu_lane_ops_c24_s1_credit, rcu_lane_ops_c24_s0_credit, rcu_lane_ops_c23_s3_credit, rcu_lane_ops_c23_s2_credit, rcu_lane_ops_c23_s1_credit, rcu_lane_ops_c23_s0_credit, rcu_lane_ops_c22_s3_credit, rcu_lane_ops_c22_s2_credit, rcu_lane_ops_c22_s1_credit, rcu_lane_ops_c22_s0_credit, rcu_lane_ops_c21_s3_credit, rcu_lane_ops_c21_s2_credit, rcu_lane_ops_c21_s1_credit, rcu_lane_ops_c21_s0_credit, rcu_lane_ops_c20_s3_credit, rcu_lane_ops_c20_s2_credit, rcu_lane_ops_c20_s1_credit, rcu_lane_ops_c20_s0_credit, rcu_lane_ops_c19_s3_credit, rcu_lane_ops_c19_s2_credit, rcu_lane_ops_c19_s1_credit, rcu_lane_ops_c19_s0_credit, rcu_lane_ops_c18_s3_credit, rcu_lane_ops_c18_s2_credit, rcu_lane_ops_c18_s1_credit, rcu_lane_ops_c18_s0_credit, rcu_lane_ops_c17_s3_credit, rcu_lane_ops_c17_s2_credit, rcu_lane_ops_c17_s1_credit, rcu_lane_ops_c17_s0_credit, rcu_lane_ops_c16_s3_credit, rcu_lane_ops_c16_s2_credit, rcu_lane_ops_c16_s1_credit, rcu_lane_ops_c16_s0_credit, rcu_lane_ops_c15_s3_credit, rcu_lane_ops_c15_s2_credit, rcu_lane_ops_c15_s1_credit, rcu_lane_ops_c15_s0_credit, rcu_lane_ops_c14_s3_credit, rcu_lane_ops_c14_s2_credit, rcu_lane_ops_c14_s1_credit, rcu_lane_ops_c14_s0_credit, rcu_lane_ops_c13_s3_credit, rcu_lane_ops_c13_s2_credit, rcu_lane_ops_c13_s1_credit, rcu_lane_ops_c13_s0_credit, rcu_lane_ops_c12_s3_credit, rcu_lane_ops_c12_s2_credit, rcu_lane_ops_c12_s1_credit, rcu_lane_ops_c12_s0_credit, rcu_lane_ops_c11_s3_credit, rcu_lane_ops_c11_s2_credit, rcu_lane_ops_c11_s1_credit, rcu_lane_ops_c11_s0_credit, rcu_lane_ops_c10_s3_credit, rcu_lane_ops_c10_s2_credit, rcu_lane_ops_c10_s1_credit, rcu_lane_ops_c10_s0_credit, rcu_lane_ops_c09_s3_credit, rcu_lane_ops_c09_s2_credit, rcu_lane_ops_c09_s1_credit, rcu_lane_ops_c09_s0_credit, rcu_lane_ops_c08_s3_credit, rcu_lane_ops_c08_s2_credit, rcu_lane_ops_c08_s1_credit, rcu_lane_ops_c08_s0_credit, rcu_lane_ops_c07_s3_credit, rcu_lane_ops_c07_s2_credit, rcu_lane_ops_c07_s1_credit, rcu_lane_ops_c07_s0_credit, rcu_lane_ops_c06_s3_credit, rcu_lane_ops_c06_s2_credit, rcu_lane_ops_c06_s1_credit, rcu_lane_ops_c06_s0_credit, rcu_lane_ops_c05_s3_credit, rcu_lane_ops_c05_s2_credit, rcu_lane_ops_c05_s1_credit, rcu_lane_ops_c05_s0_credit, rcu_lane_ops_c04_s3_credit, rcu_lane_ops_c04_s2_credit, rcu_lane_ops_c04_s1_credit, rcu_lane_ops_c04_s0_credit, rcu_lane_ops_c03_s3_credit, rcu_lane_ops_c03_s2_credit, rcu_lane_ops_c03_s1_credit, rcu_lane_ops_c03_s0_credit, rcu_lane_ops_c02_s3_credit, rcu_lane_ops_c02_s2_credit, rcu_lane_ops_c02_s1_credit, rcu_lane_ops_c02_s0_credit, rcu_lane_ops_c01_s3_credit, rcu_lane_ops_c01_s2_credit, rcu_lane_ops_c01_s1_credit, rcu_lane_ops_c01_s0_credit, rcu_lane_ops_c00_s3_credit, rcu_lane_ops_c00_s2_credit, rcu_lane_ops_c00_s1_credit, rcu_lane_ops_c00_s0_credit, ooe_rcu_issue_s3_credit, ooe_rcu_issue_s2_credit, ooe_rcu_issue_s1_credit, ooe_rcu_issue_s0_credit, dec_ooe_uop_s5_credit, dec_ooe_uop_s4_credit, dec_ooe_uop_s3_credit, dec_ooe_uop_s2_credit, dec_ooe_uop_s1_credit, dec_ooe_uop_s0_credit, fet_dec_instr_s7_credit, fet_dec_instr_s6_credit, fet_dec_instr_s5_credit, fet_dec_instr_s4_credit, fet_dec_instr_s3_credit, fet_dec_instr_s2_credit, fet_dec_instr_s1_credit, fet_dec_instr_s0_credit}),
    .stall({ext_exb_in_stall, cru_rau_cfg_stall, ooe_cru_fault_stall, rau_syu_alloc_stall, syu_ooe_rel_stall, ooe_syu_bar_stall, rau_miu_cta_stall, pca_rau_mig_done_stall, rau_fet_mig_stall, pca_fet_mig_stall, fet_pca_mig_stall, pca_rcu_mig_stall, rcu_pca_mig_stall, rau_rcu_mig_stall, ooe_rau_drained_stall, rau_ooe_demote_stall, ooe_rau_status_stall, rau_ooe_alloc_stall, rau_fet_launch_stall, exb_ext_out_stall, exb_mlc_rsp_stall, mlc_exb_req_stall, fet_miu_itlb_req_stall, miu_fet_itlb_stall, mlc_fet_ifill_rsp_stall, fet_mlc_ifill_stall, dcu_mlc_probe_ack_stall, mlc_dcu_probe_stall, mlc_dcu_rsp_stall, dcu_mlc_req_stall, dcu_miu_rsp_s3_stall, dcu_miu_rsp_s2_stall, dcu_miu_rsp_s1_stall, dcu_miu_rsp_s0_stall, miu_dcu_req_s3_stall, miu_dcu_req_s2_stall, miu_dcu_req_s1_stall, miu_dcu_req_s0_stall, spm_miu_rsp_s3_stall, spm_miu_rsp_s2_stall, spm_miu_rsp_s1_stall, spm_miu_rsp_s0_stall, miu_spm_req_s3_stall, miu_spm_req_s2_stall, miu_spm_req_s1_stall, miu_spm_req_s0_stall, ooe_fet_redirect_stall, ooe_miu_retire_s3_stall, ooe_miu_retire_s2_stall, ooe_miu_retire_s1_stall, ooe_miu_retire_s0_stall, miu_ooe_cmpl_s3_stall, miu_ooe_cmpl_s2_stall, miu_ooe_cmpl_s1_stall, miu_ooe_cmpl_s0_stall, ooe_miu_memop_s3_stall, ooe_miu_memop_s2_stall, ooe_miu_memop_s1_stall, ooe_miu_memop_s0_stall, miu_rcu_data_s3_stall, miu_rcu_data_s2_stall, miu_rcu_data_s1_stall, miu_rcu_data_s0_stall, rcu_miu_addr_s3_stall, rcu_miu_addr_s2_stall, rcu_miu_addr_s1_stall, rcu_miu_addr_s0_stall, rcu_ooe_done_s3_stall, rcu_ooe_done_s2_stall, rcu_ooe_done_s1_stall, rcu_ooe_done_s0_stall, lane_rcu_res_c31_s3_stall, lane_rcu_res_c31_s2_stall, lane_rcu_res_c31_s1_stall, lane_rcu_res_c31_s0_stall, lane_rcu_res_c30_s3_stall, lane_rcu_res_c30_s2_stall, lane_rcu_res_c30_s1_stall, lane_rcu_res_c30_s0_stall, lane_rcu_res_c29_s3_stall, lane_rcu_res_c29_s2_stall, lane_rcu_res_c29_s1_stall, lane_rcu_res_c29_s0_stall, lane_rcu_res_c28_s3_stall, lane_rcu_res_c28_s2_stall, lane_rcu_res_c28_s1_stall, lane_rcu_res_c28_s0_stall, lane_rcu_res_c27_s3_stall, lane_rcu_res_c27_s2_stall, lane_rcu_res_c27_s1_stall, lane_rcu_res_c27_s0_stall, lane_rcu_res_c26_s3_stall, lane_rcu_res_c26_s2_stall, lane_rcu_res_c26_s1_stall, lane_rcu_res_c26_s0_stall, lane_rcu_res_c25_s3_stall, lane_rcu_res_c25_s2_stall, lane_rcu_res_c25_s1_stall, lane_rcu_res_c25_s0_stall, lane_rcu_res_c24_s3_stall, lane_rcu_res_c24_s2_stall, lane_rcu_res_c24_s1_stall, lane_rcu_res_c24_s0_stall, lane_rcu_res_c23_s3_stall, lane_rcu_res_c23_s2_stall, lane_rcu_res_c23_s1_stall, lane_rcu_res_c23_s0_stall, lane_rcu_res_c22_s3_stall, lane_rcu_res_c22_s2_stall, lane_rcu_res_c22_s1_stall, lane_rcu_res_c22_s0_stall, lane_rcu_res_c21_s3_stall, lane_rcu_res_c21_s2_stall, lane_rcu_res_c21_s1_stall, lane_rcu_res_c21_s0_stall, lane_rcu_res_c20_s3_stall, lane_rcu_res_c20_s2_stall, lane_rcu_res_c20_s1_stall, lane_rcu_res_c20_s0_stall, lane_rcu_res_c19_s3_stall, lane_rcu_res_c19_s2_stall, lane_rcu_res_c19_s1_stall, lane_rcu_res_c19_s0_stall, lane_rcu_res_c18_s3_stall, lane_rcu_res_c18_s2_stall, lane_rcu_res_c18_s1_stall, lane_rcu_res_c18_s0_stall, lane_rcu_res_c17_s3_stall, lane_rcu_res_c17_s2_stall, lane_rcu_res_c17_s1_stall, lane_rcu_res_c17_s0_stall, lane_rcu_res_c16_s3_stall, lane_rcu_res_c16_s2_stall, lane_rcu_res_c16_s1_stall, lane_rcu_res_c16_s0_stall, lane_rcu_res_c15_s3_stall, lane_rcu_res_c15_s2_stall, lane_rcu_res_c15_s1_stall, lane_rcu_res_c15_s0_stall, lane_rcu_res_c14_s3_stall, lane_rcu_res_c14_s2_stall, lane_rcu_res_c14_s1_stall, lane_rcu_res_c14_s0_stall, lane_rcu_res_c13_s3_stall, lane_rcu_res_c13_s2_stall, lane_rcu_res_c13_s1_stall, lane_rcu_res_c13_s0_stall, lane_rcu_res_c12_s3_stall, lane_rcu_res_c12_s2_stall, lane_rcu_res_c12_s1_stall, lane_rcu_res_c12_s0_stall, lane_rcu_res_c11_s3_stall, lane_rcu_res_c11_s2_stall, lane_rcu_res_c11_s1_stall, lane_rcu_res_c11_s0_stall, lane_rcu_res_c10_s3_stall, lane_rcu_res_c10_s2_stall, lane_rcu_res_c10_s1_stall, lane_rcu_res_c10_s0_stall, lane_rcu_res_c09_s3_stall, lane_rcu_res_c09_s2_stall, lane_rcu_res_c09_s1_stall, lane_rcu_res_c09_s0_stall, lane_rcu_res_c08_s3_stall, lane_rcu_res_c08_s2_stall, lane_rcu_res_c08_s1_stall, lane_rcu_res_c08_s0_stall, lane_rcu_res_c07_s3_stall, lane_rcu_res_c07_s2_stall, lane_rcu_res_c07_s1_stall, lane_rcu_res_c07_s0_stall, lane_rcu_res_c06_s3_stall, lane_rcu_res_c06_s2_stall, lane_rcu_res_c06_s1_stall, lane_rcu_res_c06_s0_stall, lane_rcu_res_c05_s3_stall, lane_rcu_res_c05_s2_stall, lane_rcu_res_c05_s1_stall, lane_rcu_res_c05_s0_stall, lane_rcu_res_c04_s3_stall, lane_rcu_res_c04_s2_stall, lane_rcu_res_c04_s1_stall, lane_rcu_res_c04_s0_stall, lane_rcu_res_c03_s3_stall, lane_rcu_res_c03_s2_stall, lane_rcu_res_c03_s1_stall, lane_rcu_res_c03_s0_stall, lane_rcu_res_c02_s3_stall, lane_rcu_res_c02_s2_stall, lane_rcu_res_c02_s1_stall, lane_rcu_res_c02_s0_stall, lane_rcu_res_c01_s3_stall, lane_rcu_res_c01_s2_stall, lane_rcu_res_c01_s1_stall, lane_rcu_res_c01_s0_stall, lane_rcu_res_c00_s3_stall, lane_rcu_res_c00_s2_stall, lane_rcu_res_c00_s1_stall, lane_rcu_res_c00_s0_stall, rcu_lane_ops_c31_s3_stall, rcu_lane_ops_c31_s2_stall, rcu_lane_ops_c31_s1_stall, rcu_lane_ops_c31_s0_stall, rcu_lane_ops_c30_s3_stall, rcu_lane_ops_c30_s2_stall, rcu_lane_ops_c30_s1_stall, rcu_lane_ops_c30_s0_stall, rcu_lane_ops_c29_s3_stall, rcu_lane_ops_c29_s2_stall, rcu_lane_ops_c29_s1_stall, rcu_lane_ops_c29_s0_stall, rcu_lane_ops_c28_s3_stall, rcu_lane_ops_c28_s2_stall, rcu_lane_ops_c28_s1_stall, rcu_lane_ops_c28_s0_stall, rcu_lane_ops_c27_s3_stall, rcu_lane_ops_c27_s2_stall, rcu_lane_ops_c27_s1_stall, rcu_lane_ops_c27_s0_stall, rcu_lane_ops_c26_s3_stall, rcu_lane_ops_c26_s2_stall, rcu_lane_ops_c26_s1_stall, rcu_lane_ops_c26_s0_stall, rcu_lane_ops_c25_s3_stall, rcu_lane_ops_c25_s2_stall, rcu_lane_ops_c25_s1_stall, rcu_lane_ops_c25_s0_stall, rcu_lane_ops_c24_s3_stall, rcu_lane_ops_c24_s2_stall, rcu_lane_ops_c24_s1_stall, rcu_lane_ops_c24_s0_stall, rcu_lane_ops_c23_s3_stall, rcu_lane_ops_c23_s2_stall, rcu_lane_ops_c23_s1_stall, rcu_lane_ops_c23_s0_stall, rcu_lane_ops_c22_s3_stall, rcu_lane_ops_c22_s2_stall, rcu_lane_ops_c22_s1_stall, rcu_lane_ops_c22_s0_stall, rcu_lane_ops_c21_s3_stall, rcu_lane_ops_c21_s2_stall, rcu_lane_ops_c21_s1_stall, rcu_lane_ops_c21_s0_stall, rcu_lane_ops_c20_s3_stall, rcu_lane_ops_c20_s2_stall, rcu_lane_ops_c20_s1_stall, rcu_lane_ops_c20_s0_stall, rcu_lane_ops_c19_s3_stall, rcu_lane_ops_c19_s2_stall, rcu_lane_ops_c19_s1_stall, rcu_lane_ops_c19_s0_stall, rcu_lane_ops_c18_s3_stall, rcu_lane_ops_c18_s2_stall, rcu_lane_ops_c18_s1_stall, rcu_lane_ops_c18_s0_stall, rcu_lane_ops_c17_s3_stall, rcu_lane_ops_c17_s2_stall, rcu_lane_ops_c17_s1_stall, rcu_lane_ops_c17_s0_stall, rcu_lane_ops_c16_s3_stall, rcu_lane_ops_c16_s2_stall, rcu_lane_ops_c16_s1_stall, rcu_lane_ops_c16_s0_stall, rcu_lane_ops_c15_s3_stall, rcu_lane_ops_c15_s2_stall, rcu_lane_ops_c15_s1_stall, rcu_lane_ops_c15_s0_stall, rcu_lane_ops_c14_s3_stall, rcu_lane_ops_c14_s2_stall, rcu_lane_ops_c14_s1_stall, rcu_lane_ops_c14_s0_stall, rcu_lane_ops_c13_s3_stall, rcu_lane_ops_c13_s2_stall, rcu_lane_ops_c13_s1_stall, rcu_lane_ops_c13_s0_stall, rcu_lane_ops_c12_s3_stall, rcu_lane_ops_c12_s2_stall, rcu_lane_ops_c12_s1_stall, rcu_lane_ops_c12_s0_stall, rcu_lane_ops_c11_s3_stall, rcu_lane_ops_c11_s2_stall, rcu_lane_ops_c11_s1_stall, rcu_lane_ops_c11_s0_stall, rcu_lane_ops_c10_s3_stall, rcu_lane_ops_c10_s2_stall, rcu_lane_ops_c10_s1_stall, rcu_lane_ops_c10_s0_stall, rcu_lane_ops_c09_s3_stall, rcu_lane_ops_c09_s2_stall, rcu_lane_ops_c09_s1_stall, rcu_lane_ops_c09_s0_stall, rcu_lane_ops_c08_s3_stall, rcu_lane_ops_c08_s2_stall, rcu_lane_ops_c08_s1_stall, rcu_lane_ops_c08_s0_stall, rcu_lane_ops_c07_s3_stall, rcu_lane_ops_c07_s2_stall, rcu_lane_ops_c07_s1_stall, rcu_lane_ops_c07_s0_stall, rcu_lane_ops_c06_s3_stall, rcu_lane_ops_c06_s2_stall, rcu_lane_ops_c06_s1_stall, rcu_lane_ops_c06_s0_stall, rcu_lane_ops_c05_s3_stall, rcu_lane_ops_c05_s2_stall, rcu_lane_ops_c05_s1_stall, rcu_lane_ops_c05_s0_stall, rcu_lane_ops_c04_s3_stall, rcu_lane_ops_c04_s2_stall, rcu_lane_ops_c04_s1_stall, rcu_lane_ops_c04_s0_stall, rcu_lane_ops_c03_s3_stall, rcu_lane_ops_c03_s2_stall, rcu_lane_ops_c03_s1_stall, rcu_lane_ops_c03_s0_stall, rcu_lane_ops_c02_s3_stall, rcu_lane_ops_c02_s2_stall, rcu_lane_ops_c02_s1_stall, rcu_lane_ops_c02_s0_stall, rcu_lane_ops_c01_s3_stall, rcu_lane_ops_c01_s2_stall, rcu_lane_ops_c01_s1_stall, rcu_lane_ops_c01_s0_stall, rcu_lane_ops_c00_s3_stall, rcu_lane_ops_c00_s2_stall, rcu_lane_ops_c00_s1_stall, rcu_lane_ops_c00_s0_stall, ooe_rcu_issue_s3_stall, ooe_rcu_issue_s2_stall, ooe_rcu_issue_s1_stall, ooe_rcu_issue_s0_stall, dec_ooe_uop_s5_stall, dec_ooe_uop_s4_stall, dec_ooe_uop_s3_stall, dec_ooe_uop_s2_stall, dec_ooe_uop_s1_stall, dec_ooe_uop_s0_stall, fet_dec_instr_s7_stall, fet_dec_instr_s6_stall, fet_dec_instr_s5_stall, fet_dec_instr_s4_stall, fet_dec_instr_s3_stall, fet_dec_instr_s2_stall, fet_dec_instr_s1_stall, fet_dec_instr_s0_stall}),
    .payload({ext_exb_in_payload, cru_rau_cfg_payload, ooe_cru_fault_payload, rau_syu_alloc_payload, syu_ooe_rel_payload, ooe_syu_bar_payload, rau_miu_cta_payload, pca_rau_mig_done_payload, rau_fet_mig_payload, pca_fet_mig_payload, fet_pca_mig_payload, pca_rcu_mig_payload, rcu_pca_mig_payload, rau_rcu_mig_payload, ooe_rau_drained_payload, rau_ooe_demote_payload, ooe_rau_status_payload, rau_ooe_alloc_payload, rau_fet_launch_payload, exb_ext_out_payload, exb_mlc_rsp_payload, mlc_exb_req_payload, fet_miu_itlb_req_payload, miu_fet_itlb_payload, mlc_fet_ifill_rsp_payload, fet_mlc_ifill_payload, dcu_mlc_probe_ack_payload, mlc_dcu_probe_payload, mlc_dcu_rsp_payload, dcu_mlc_req_payload, dcu_miu_rsp_s3_payload, dcu_miu_rsp_s2_payload, dcu_miu_rsp_s1_payload, dcu_miu_rsp_s0_payload, miu_dcu_req_s3_payload, miu_dcu_req_s2_payload, miu_dcu_req_s1_payload, miu_dcu_req_s0_payload, spm_miu_rsp_s3_payload, spm_miu_rsp_s2_payload, spm_miu_rsp_s1_payload, spm_miu_rsp_s0_payload, miu_spm_req_s3_payload, miu_spm_req_s2_payload, miu_spm_req_s1_payload, miu_spm_req_s0_payload, ooe_fet_redirect_payload, ooe_miu_retire_s3_payload, ooe_miu_retire_s2_payload, ooe_miu_retire_s1_payload, ooe_miu_retire_s0_payload, miu_ooe_cmpl_s3_payload, miu_ooe_cmpl_s2_payload, miu_ooe_cmpl_s1_payload, miu_ooe_cmpl_s0_payload, ooe_miu_memop_s3_payload, ooe_miu_memop_s2_payload, ooe_miu_memop_s1_payload, ooe_miu_memop_s0_payload, miu_rcu_data_s3_payload, miu_rcu_data_s2_payload, miu_rcu_data_s1_payload, miu_rcu_data_s0_payload, rcu_miu_addr_s3_payload, rcu_miu_addr_s2_payload, rcu_miu_addr_s1_payload, rcu_miu_addr_s0_payload, rcu_ooe_done_s3_payload, rcu_ooe_done_s2_payload, rcu_ooe_done_s1_payload, rcu_ooe_done_s0_payload, lane_rcu_res_c31_s3_payload, lane_rcu_res_c31_s2_payload, lane_rcu_res_c31_s1_payload, lane_rcu_res_c31_s0_payload, lane_rcu_res_c30_s3_payload, lane_rcu_res_c30_s2_payload, lane_rcu_res_c30_s1_payload, lane_rcu_res_c30_s0_payload, lane_rcu_res_c29_s3_payload, lane_rcu_res_c29_s2_payload, lane_rcu_res_c29_s1_payload, lane_rcu_res_c29_s0_payload, lane_rcu_res_c28_s3_payload, lane_rcu_res_c28_s2_payload, lane_rcu_res_c28_s1_payload, lane_rcu_res_c28_s0_payload, lane_rcu_res_c27_s3_payload, lane_rcu_res_c27_s2_payload, lane_rcu_res_c27_s1_payload, lane_rcu_res_c27_s0_payload, lane_rcu_res_c26_s3_payload, lane_rcu_res_c26_s2_payload, lane_rcu_res_c26_s1_payload, lane_rcu_res_c26_s0_payload, lane_rcu_res_c25_s3_payload, lane_rcu_res_c25_s2_payload, lane_rcu_res_c25_s1_payload, lane_rcu_res_c25_s0_payload, lane_rcu_res_c24_s3_payload, lane_rcu_res_c24_s2_payload, lane_rcu_res_c24_s1_payload, lane_rcu_res_c24_s0_payload, lane_rcu_res_c23_s3_payload, lane_rcu_res_c23_s2_payload, lane_rcu_res_c23_s1_payload, lane_rcu_res_c23_s0_payload, lane_rcu_res_c22_s3_payload, lane_rcu_res_c22_s2_payload, lane_rcu_res_c22_s1_payload, lane_rcu_res_c22_s0_payload, lane_rcu_res_c21_s3_payload, lane_rcu_res_c21_s2_payload, lane_rcu_res_c21_s1_payload, lane_rcu_res_c21_s0_payload, lane_rcu_res_c20_s3_payload, lane_rcu_res_c20_s2_payload, lane_rcu_res_c20_s1_payload, lane_rcu_res_c20_s0_payload, lane_rcu_res_c19_s3_payload, lane_rcu_res_c19_s2_payload, lane_rcu_res_c19_s1_payload, lane_rcu_res_c19_s0_payload, lane_rcu_res_c18_s3_payload, lane_rcu_res_c18_s2_payload, lane_rcu_res_c18_s1_payload, lane_rcu_res_c18_s0_payload, lane_rcu_res_c17_s3_payload, lane_rcu_res_c17_s2_payload, lane_rcu_res_c17_s1_payload, lane_rcu_res_c17_s0_payload, lane_rcu_res_c16_s3_payload, lane_rcu_res_c16_s2_payload, lane_rcu_res_c16_s1_payload, lane_rcu_res_c16_s0_payload, lane_rcu_res_c15_s3_payload, lane_rcu_res_c15_s2_payload, lane_rcu_res_c15_s1_payload, lane_rcu_res_c15_s0_payload, lane_rcu_res_c14_s3_payload, lane_rcu_res_c14_s2_payload, lane_rcu_res_c14_s1_payload, lane_rcu_res_c14_s0_payload, lane_rcu_res_c13_s3_payload, lane_rcu_res_c13_s2_payload, lane_rcu_res_c13_s1_payload, lane_rcu_res_c13_s0_payload, lane_rcu_res_c12_s3_payload, lane_rcu_res_c12_s2_payload, lane_rcu_res_c12_s1_payload, lane_rcu_res_c12_s0_payload, lane_rcu_res_c11_s3_payload, lane_rcu_res_c11_s2_payload, lane_rcu_res_c11_s1_payload, lane_rcu_res_c11_s0_payload, lane_rcu_res_c10_s3_payload, lane_rcu_res_c10_s2_payload, lane_rcu_res_c10_s1_payload, lane_rcu_res_c10_s0_payload, lane_rcu_res_c09_s3_payload, lane_rcu_res_c09_s2_payload, lane_rcu_res_c09_s1_payload, lane_rcu_res_c09_s0_payload, lane_rcu_res_c08_s3_payload, lane_rcu_res_c08_s2_payload, lane_rcu_res_c08_s1_payload, lane_rcu_res_c08_s0_payload, lane_rcu_res_c07_s3_payload, lane_rcu_res_c07_s2_payload, lane_rcu_res_c07_s1_payload, lane_rcu_res_c07_s0_payload, lane_rcu_res_c06_s3_payload, lane_rcu_res_c06_s2_payload, lane_rcu_res_c06_s1_payload, lane_rcu_res_c06_s0_payload, lane_rcu_res_c05_s3_payload, lane_rcu_res_c05_s2_payload, lane_rcu_res_c05_s1_payload, lane_rcu_res_c05_s0_payload, lane_rcu_res_c04_s3_payload, lane_rcu_res_c04_s2_payload, lane_rcu_res_c04_s1_payload, lane_rcu_res_c04_s0_payload, lane_rcu_res_c03_s3_payload, lane_rcu_res_c03_s2_payload, lane_rcu_res_c03_s1_payload, lane_rcu_res_c03_s0_payload, lane_rcu_res_c02_s3_payload, lane_rcu_res_c02_s2_payload, lane_rcu_res_c02_s1_payload, lane_rcu_res_c02_s0_payload, lane_rcu_res_c01_s3_payload, lane_rcu_res_c01_s2_payload, lane_rcu_res_c01_s1_payload, lane_rcu_res_c01_s0_payload, lane_rcu_res_c00_s3_payload, lane_rcu_res_c00_s2_payload, lane_rcu_res_c00_s1_payload, lane_rcu_res_c00_s0_payload, rcu_lane_ops_c31_s3_payload, rcu_lane_ops_c31_s2_payload, rcu_lane_ops_c31_s1_payload, rcu_lane_ops_c31_s0_payload, rcu_lane_ops_c30_s3_payload, rcu_lane_ops_c30_s2_payload, rcu_lane_ops_c30_s1_payload, rcu_lane_ops_c30_s0_payload, rcu_lane_ops_c29_s3_payload, rcu_lane_ops_c29_s2_payload, rcu_lane_ops_c29_s1_payload, rcu_lane_ops_c29_s0_payload, rcu_lane_ops_c28_s3_payload, rcu_lane_ops_c28_s2_payload, rcu_lane_ops_c28_s1_payload, rcu_lane_ops_c28_s0_payload, rcu_lane_ops_c27_s3_payload, rcu_lane_ops_c27_s2_payload, rcu_lane_ops_c27_s1_payload, rcu_lane_ops_c27_s0_payload, rcu_lane_ops_c26_s3_payload, rcu_lane_ops_c26_s2_payload, rcu_lane_ops_c26_s1_payload, rcu_lane_ops_c26_s0_payload, rcu_lane_ops_c25_s3_payload, rcu_lane_ops_c25_s2_payload, rcu_lane_ops_c25_s1_payload, rcu_lane_ops_c25_s0_payload, rcu_lane_ops_c24_s3_payload, rcu_lane_ops_c24_s2_payload, rcu_lane_ops_c24_s1_payload, rcu_lane_ops_c24_s0_payload, rcu_lane_ops_c23_s3_payload, rcu_lane_ops_c23_s2_payload, rcu_lane_ops_c23_s1_payload, rcu_lane_ops_c23_s0_payload, rcu_lane_ops_c22_s3_payload, rcu_lane_ops_c22_s2_payload, rcu_lane_ops_c22_s1_payload, rcu_lane_ops_c22_s0_payload, rcu_lane_ops_c21_s3_payload, rcu_lane_ops_c21_s2_payload, rcu_lane_ops_c21_s1_payload, rcu_lane_ops_c21_s0_payload, rcu_lane_ops_c20_s3_payload, rcu_lane_ops_c20_s2_payload, rcu_lane_ops_c20_s1_payload, rcu_lane_ops_c20_s0_payload, rcu_lane_ops_c19_s3_payload, rcu_lane_ops_c19_s2_payload, rcu_lane_ops_c19_s1_payload, rcu_lane_ops_c19_s0_payload, rcu_lane_ops_c18_s3_payload, rcu_lane_ops_c18_s2_payload, rcu_lane_ops_c18_s1_payload, rcu_lane_ops_c18_s0_payload, rcu_lane_ops_c17_s3_payload, rcu_lane_ops_c17_s2_payload, rcu_lane_ops_c17_s1_payload, rcu_lane_ops_c17_s0_payload, rcu_lane_ops_c16_s3_payload, rcu_lane_ops_c16_s2_payload, rcu_lane_ops_c16_s1_payload, rcu_lane_ops_c16_s0_payload, rcu_lane_ops_c15_s3_payload, rcu_lane_ops_c15_s2_payload, rcu_lane_ops_c15_s1_payload, rcu_lane_ops_c15_s0_payload, rcu_lane_ops_c14_s3_payload, rcu_lane_ops_c14_s2_payload, rcu_lane_ops_c14_s1_payload, rcu_lane_ops_c14_s0_payload, rcu_lane_ops_c13_s3_payload, rcu_lane_ops_c13_s2_payload, rcu_lane_ops_c13_s1_payload, rcu_lane_ops_c13_s0_payload, rcu_lane_ops_c12_s3_payload, rcu_lane_ops_c12_s2_payload, rcu_lane_ops_c12_s1_payload, rcu_lane_ops_c12_s0_payload, rcu_lane_ops_c11_s3_payload, rcu_lane_ops_c11_s2_payload, rcu_lane_ops_c11_s1_payload, rcu_lane_ops_c11_s0_payload, rcu_lane_ops_c10_s3_payload, rcu_lane_ops_c10_s2_payload, rcu_lane_ops_c10_s1_payload, rcu_lane_ops_c10_s0_payload, rcu_lane_ops_c09_s3_payload, rcu_lane_ops_c09_s2_payload, rcu_lane_ops_c09_s1_payload, rcu_lane_ops_c09_s0_payload, rcu_lane_ops_c08_s3_payload, rcu_lane_ops_c08_s2_payload, rcu_lane_ops_c08_s1_payload, rcu_lane_ops_c08_s0_payload, rcu_lane_ops_c07_s3_payload, rcu_lane_ops_c07_s2_payload, rcu_lane_ops_c07_s1_payload, rcu_lane_ops_c07_s0_payload, rcu_lane_ops_c06_s3_payload, rcu_lane_ops_c06_s2_payload, rcu_lane_ops_c06_s1_payload, rcu_lane_ops_c06_s0_payload, rcu_lane_ops_c05_s3_payload, rcu_lane_ops_c05_s2_payload, rcu_lane_ops_c05_s1_payload, rcu_lane_ops_c05_s0_payload, rcu_lane_ops_c04_s3_payload, rcu_lane_ops_c04_s2_payload, rcu_lane_ops_c04_s1_payload, rcu_lane_ops_c04_s0_payload, rcu_lane_ops_c03_s3_payload, rcu_lane_ops_c03_s2_payload, rcu_lane_ops_c03_s1_payload, rcu_lane_ops_c03_s0_payload, rcu_lane_ops_c02_s3_payload, rcu_lane_ops_c02_s2_payload, rcu_lane_ops_c02_s1_payload, rcu_lane_ops_c02_s0_payload, rcu_lane_ops_c01_s3_payload, rcu_lane_ops_c01_s2_payload, rcu_lane_ops_c01_s1_payload, rcu_lane_ops_c01_s0_payload, rcu_lane_ops_c00_s3_payload, rcu_lane_ops_c00_s2_payload, rcu_lane_ops_c00_s1_payload, rcu_lane_ops_c00_s0_payload, ooe_rcu_issue_s3_payload, ooe_rcu_issue_s2_payload, ooe_rcu_issue_s1_payload, ooe_rcu_issue_s0_payload, dec_ooe_uop_s5_payload, dec_ooe_uop_s4_payload, dec_ooe_uop_s3_payload, dec_ooe_uop_s2_payload, dec_ooe_uop_s1_payload, dec_ooe_uop_s0_payload, fet_dec_instr_s7_payload, fet_dec_instr_s6_payload, fet_dec_instr_s5_payload, fet_dec_instr_s4_payload, fet_dec_instr_s3_payload, fet_dec_instr_s2_payload, fet_dec_instr_s1_payload, fet_dec_instr_s0_payload}),
    .wake({ext_exb_in_wake, cru_rau_cfg_wake, ooe_cru_fault_wake, rau_syu_alloc_wake, syu_ooe_rel_wake, ooe_syu_bar_wake, rau_miu_cta_wake, pca_rau_mig_done_wake, rau_fet_mig_wake, pca_fet_mig_wake, fet_pca_mig_wake, pca_rcu_mig_wake, rcu_pca_mig_wake, rau_rcu_mig_wake, ooe_rau_drained_wake, rau_ooe_demote_wake, ooe_rau_status_wake, rau_ooe_alloc_wake, rau_fet_launch_wake, exb_ext_out_wake, exb_mlc_rsp_wake, mlc_exb_req_wake, fet_miu_itlb_req_wake, miu_fet_itlb_wake, mlc_fet_ifill_rsp_wake, fet_mlc_ifill_wake, dcu_mlc_probe_ack_wake, mlc_dcu_probe_wake, mlc_dcu_rsp_wake, dcu_mlc_req_wake, dcu_miu_rsp_wake, miu_dcu_req_wake, spm_miu_rsp_wake, miu_spm_req_wake, ooe_fet_redirect_wake, ooe_miu_retire_wake, miu_ooe_cmpl_wake, ooe_miu_memop_wake, miu_rcu_data_wake, rcu_miu_addr_wake, rcu_ooe_done_wake, lane_rcu_res_c31_wake, lane_rcu_res_c30_wake, lane_rcu_res_c29_wake, lane_rcu_res_c28_wake, lane_rcu_res_c27_wake, lane_rcu_res_c26_wake, lane_rcu_res_c25_wake, lane_rcu_res_c24_wake, lane_rcu_res_c23_wake, lane_rcu_res_c22_wake, lane_rcu_res_c21_wake, lane_rcu_res_c20_wake, lane_rcu_res_c19_wake, lane_rcu_res_c18_wake, lane_rcu_res_c17_wake, lane_rcu_res_c16_wake, lane_rcu_res_c15_wake, lane_rcu_res_c14_wake, lane_rcu_res_c13_wake, lane_rcu_res_c12_wake, lane_rcu_res_c11_wake, lane_rcu_res_c10_wake, lane_rcu_res_c09_wake, lane_rcu_res_c08_wake, lane_rcu_res_c07_wake, lane_rcu_res_c06_wake, lane_rcu_res_c05_wake, lane_rcu_res_c04_wake, lane_rcu_res_c03_wake, lane_rcu_res_c02_wake, lane_rcu_res_c01_wake, lane_rcu_res_c00_wake, rcu_lane_ops_c31_wake, rcu_lane_ops_c30_wake, rcu_lane_ops_c29_wake, rcu_lane_ops_c28_wake, rcu_lane_ops_c27_wake, rcu_lane_ops_c26_wake, rcu_lane_ops_c25_wake, rcu_lane_ops_c24_wake, rcu_lane_ops_c23_wake, rcu_lane_ops_c22_wake, rcu_lane_ops_c21_wake, rcu_lane_ops_c20_wake, rcu_lane_ops_c19_wake, rcu_lane_ops_c18_wake, rcu_lane_ops_c17_wake, rcu_lane_ops_c16_wake, rcu_lane_ops_c15_wake, rcu_lane_ops_c14_wake, rcu_lane_ops_c13_wake, rcu_lane_ops_c12_wake, rcu_lane_ops_c11_wake, rcu_lane_ops_c10_wake, rcu_lane_ops_c09_wake, rcu_lane_ops_c08_wake, rcu_lane_ops_c07_wake, rcu_lane_ops_c06_wake, rcu_lane_ops_c05_wake, rcu_lane_ops_c04_wake, rcu_lane_ops_c03_wake, rcu_lane_ops_c02_wake, rcu_lane_ops_c01_wake, rcu_lane_ops_c00_wake, ooe_rcu_issue_wake, dec_ooe_uop_wake, fet_dec_instr_wake}),
    .rx_gated({exb_sleep_ok, rau_sleep_ok, cru_sleep_ok, syu_sleep_ok, ooe_sleep_ok, syu_sleep_ok, miu_sleep_ok, rau_sleep_ok, fet_sleep_ok, fet_sleep_ok, pca_sleep_ok, rcu_sleep_ok, pca_sleep_ok, rcu_sleep_ok, rau_sleep_ok, ooe_sleep_ok, rau_sleep_ok, ooe_sleep_ok, fet_sleep_ok, 1'b0, mlc_sleep_ok, exb_sleep_ok, miu_sleep_ok, fet_sleep_ok, fet_sleep_ok, mlc_sleep_ok, mlc_sleep_ok, dcu_sleep_ok, dcu_sleep_ok, mlc_sleep_ok, miu_sleep_ok, dcu_sleep_ok, miu_sleep_ok, spm_sleep_ok, fet_sleep_ok, miu_sleep_ok, ooe_sleep_ok, miu_sleep_ok, rcu_sleep_ok, miu_sleep_ok, ooe_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, rcu_sleep_ok, lane_31_sleep_ok, lane_30_sleep_ok, lane_29_sleep_ok, lane_28_sleep_ok, lane_27_sleep_ok, lane_26_sleep_ok, lane_25_sleep_ok, lane_24_sleep_ok, lane_23_sleep_ok, lane_22_sleep_ok, lane_21_sleep_ok, lane_20_sleep_ok, lane_19_sleep_ok, lane_18_sleep_ok, lane_17_sleep_ok, lane_16_sleep_ok, lane_15_sleep_ok, lane_14_sleep_ok, lane_13_sleep_ok, lane_12_sleep_ok, lane_11_sleep_ok, lane_10_sleep_ok, lane_09_sleep_ok, lane_08_sleep_ok, lane_07_sleep_ok, lane_06_sleep_ok, lane_05_sleep_ok, lane_04_sleep_ok, lane_03_sleep_ok, lane_02_sleep_ok, lane_01_sleep_ok, lane_00_sleep_ok, rcu_sleep_ok, ooe_sleep_ok, dec_sleep_ok})
`ifdef CCV_TRACE
    , .tid({ext_exb_in_tid, cru_rau_cfg_tid, ooe_cru_fault_tid, rau_syu_alloc_tid, syu_ooe_rel_tid, ooe_syu_bar_tid, rau_miu_cta_tid, pca_rau_mig_done_tid, rau_fet_mig_tid, pca_fet_mig_tid, fet_pca_mig_tid, pca_rcu_mig_tid, rcu_pca_mig_tid, rau_rcu_mig_tid, ooe_rau_drained_tid, rau_ooe_demote_tid, ooe_rau_status_tid, rau_ooe_alloc_tid, rau_fet_launch_tid, exb_ext_out_tid, exb_mlc_rsp_tid, mlc_exb_req_tid, fet_miu_itlb_req_tid, miu_fet_itlb_tid, mlc_fet_ifill_rsp_tid, fet_mlc_ifill_tid, dcu_mlc_probe_ack_tid, mlc_dcu_probe_tid, mlc_dcu_rsp_tid, dcu_mlc_req_tid, dcu_miu_rsp_s3_tid, dcu_miu_rsp_s2_tid, dcu_miu_rsp_s1_tid, dcu_miu_rsp_s0_tid, miu_dcu_req_s3_tid, miu_dcu_req_s2_tid, miu_dcu_req_s1_tid, miu_dcu_req_s0_tid, spm_miu_rsp_s3_tid, spm_miu_rsp_s2_tid, spm_miu_rsp_s1_tid, spm_miu_rsp_s0_tid, miu_spm_req_s3_tid, miu_spm_req_s2_tid, miu_spm_req_s1_tid, miu_spm_req_s0_tid, ooe_fet_redirect_tid, ooe_miu_retire_s3_tid, ooe_miu_retire_s2_tid, ooe_miu_retire_s1_tid, ooe_miu_retire_s0_tid, miu_ooe_cmpl_s3_tid, miu_ooe_cmpl_s2_tid, miu_ooe_cmpl_s1_tid, miu_ooe_cmpl_s0_tid, ooe_miu_memop_s3_tid, ooe_miu_memop_s2_tid, ooe_miu_memop_s1_tid, ooe_miu_memop_s0_tid, miu_rcu_data_s3_tid, miu_rcu_data_s2_tid, miu_rcu_data_s1_tid, miu_rcu_data_s0_tid, rcu_miu_addr_s3_tid, rcu_miu_addr_s2_tid, rcu_miu_addr_s1_tid, rcu_miu_addr_s0_tid, rcu_ooe_done_s3_tid, rcu_ooe_done_s2_tid, rcu_ooe_done_s1_tid, rcu_ooe_done_s0_tid, lane_rcu_res_c31_s3_tid, lane_rcu_res_c31_s2_tid, lane_rcu_res_c31_s1_tid, lane_rcu_res_c31_s0_tid, lane_rcu_res_c30_s3_tid, lane_rcu_res_c30_s2_tid, lane_rcu_res_c30_s1_tid, lane_rcu_res_c30_s0_tid, lane_rcu_res_c29_s3_tid, lane_rcu_res_c29_s2_tid, lane_rcu_res_c29_s1_tid, lane_rcu_res_c29_s0_tid, lane_rcu_res_c28_s3_tid, lane_rcu_res_c28_s2_tid, lane_rcu_res_c28_s1_tid, lane_rcu_res_c28_s0_tid, lane_rcu_res_c27_s3_tid, lane_rcu_res_c27_s2_tid, lane_rcu_res_c27_s1_tid, lane_rcu_res_c27_s0_tid, lane_rcu_res_c26_s3_tid, lane_rcu_res_c26_s2_tid, lane_rcu_res_c26_s1_tid, lane_rcu_res_c26_s0_tid, lane_rcu_res_c25_s3_tid, lane_rcu_res_c25_s2_tid, lane_rcu_res_c25_s1_tid, lane_rcu_res_c25_s0_tid, lane_rcu_res_c24_s3_tid, lane_rcu_res_c24_s2_tid, lane_rcu_res_c24_s1_tid, lane_rcu_res_c24_s0_tid, lane_rcu_res_c23_s3_tid, lane_rcu_res_c23_s2_tid, lane_rcu_res_c23_s1_tid, lane_rcu_res_c23_s0_tid, lane_rcu_res_c22_s3_tid, lane_rcu_res_c22_s2_tid, lane_rcu_res_c22_s1_tid, lane_rcu_res_c22_s0_tid, lane_rcu_res_c21_s3_tid, lane_rcu_res_c21_s2_tid, lane_rcu_res_c21_s1_tid, lane_rcu_res_c21_s0_tid, lane_rcu_res_c20_s3_tid, lane_rcu_res_c20_s2_tid, lane_rcu_res_c20_s1_tid, lane_rcu_res_c20_s0_tid, lane_rcu_res_c19_s3_tid, lane_rcu_res_c19_s2_tid, lane_rcu_res_c19_s1_tid, lane_rcu_res_c19_s0_tid, lane_rcu_res_c18_s3_tid, lane_rcu_res_c18_s2_tid, lane_rcu_res_c18_s1_tid, lane_rcu_res_c18_s0_tid, lane_rcu_res_c17_s3_tid, lane_rcu_res_c17_s2_tid, lane_rcu_res_c17_s1_tid, lane_rcu_res_c17_s0_tid, lane_rcu_res_c16_s3_tid, lane_rcu_res_c16_s2_tid, lane_rcu_res_c16_s1_tid, lane_rcu_res_c16_s0_tid, lane_rcu_res_c15_s3_tid, lane_rcu_res_c15_s2_tid, lane_rcu_res_c15_s1_tid, lane_rcu_res_c15_s0_tid, lane_rcu_res_c14_s3_tid, lane_rcu_res_c14_s2_tid, lane_rcu_res_c14_s1_tid, lane_rcu_res_c14_s0_tid, lane_rcu_res_c13_s3_tid, lane_rcu_res_c13_s2_tid, lane_rcu_res_c13_s1_tid, lane_rcu_res_c13_s0_tid, lane_rcu_res_c12_s3_tid, lane_rcu_res_c12_s2_tid, lane_rcu_res_c12_s1_tid, lane_rcu_res_c12_s0_tid, lane_rcu_res_c11_s3_tid, lane_rcu_res_c11_s2_tid, lane_rcu_res_c11_s1_tid, lane_rcu_res_c11_s0_tid, lane_rcu_res_c10_s3_tid, lane_rcu_res_c10_s2_tid, lane_rcu_res_c10_s1_tid, lane_rcu_res_c10_s0_tid, lane_rcu_res_c09_s3_tid, lane_rcu_res_c09_s2_tid, lane_rcu_res_c09_s1_tid, lane_rcu_res_c09_s0_tid, lane_rcu_res_c08_s3_tid, lane_rcu_res_c08_s2_tid, lane_rcu_res_c08_s1_tid, lane_rcu_res_c08_s0_tid, lane_rcu_res_c07_s3_tid, lane_rcu_res_c07_s2_tid, lane_rcu_res_c07_s1_tid, lane_rcu_res_c07_s0_tid, lane_rcu_res_c06_s3_tid, lane_rcu_res_c06_s2_tid, lane_rcu_res_c06_s1_tid, lane_rcu_res_c06_s0_tid, lane_rcu_res_c05_s3_tid, lane_rcu_res_c05_s2_tid, lane_rcu_res_c05_s1_tid, lane_rcu_res_c05_s0_tid, lane_rcu_res_c04_s3_tid, lane_rcu_res_c04_s2_tid, lane_rcu_res_c04_s1_tid, lane_rcu_res_c04_s0_tid, lane_rcu_res_c03_s3_tid, lane_rcu_res_c03_s2_tid, lane_rcu_res_c03_s1_tid, lane_rcu_res_c03_s0_tid, lane_rcu_res_c02_s3_tid, lane_rcu_res_c02_s2_tid, lane_rcu_res_c02_s1_tid, lane_rcu_res_c02_s0_tid, lane_rcu_res_c01_s3_tid, lane_rcu_res_c01_s2_tid, lane_rcu_res_c01_s1_tid, lane_rcu_res_c01_s0_tid, lane_rcu_res_c00_s3_tid, lane_rcu_res_c00_s2_tid, lane_rcu_res_c00_s1_tid, lane_rcu_res_c00_s0_tid, rcu_lane_ops_c31_s3_tid, rcu_lane_ops_c31_s2_tid, rcu_lane_ops_c31_s1_tid, rcu_lane_ops_c31_s0_tid, rcu_lane_ops_c30_s3_tid, rcu_lane_ops_c30_s2_tid, rcu_lane_ops_c30_s1_tid, rcu_lane_ops_c30_s0_tid, rcu_lane_ops_c29_s3_tid, rcu_lane_ops_c29_s2_tid, rcu_lane_ops_c29_s1_tid, rcu_lane_ops_c29_s0_tid, rcu_lane_ops_c28_s3_tid, rcu_lane_ops_c28_s2_tid, rcu_lane_ops_c28_s1_tid, rcu_lane_ops_c28_s0_tid, rcu_lane_ops_c27_s3_tid, rcu_lane_ops_c27_s2_tid, rcu_lane_ops_c27_s1_tid, rcu_lane_ops_c27_s0_tid, rcu_lane_ops_c26_s3_tid, rcu_lane_ops_c26_s2_tid, rcu_lane_ops_c26_s1_tid, rcu_lane_ops_c26_s0_tid, rcu_lane_ops_c25_s3_tid, rcu_lane_ops_c25_s2_tid, rcu_lane_ops_c25_s1_tid, rcu_lane_ops_c25_s0_tid, rcu_lane_ops_c24_s3_tid, rcu_lane_ops_c24_s2_tid, rcu_lane_ops_c24_s1_tid, rcu_lane_ops_c24_s0_tid, rcu_lane_ops_c23_s3_tid, rcu_lane_ops_c23_s2_tid, rcu_lane_ops_c23_s1_tid, rcu_lane_ops_c23_s0_tid, rcu_lane_ops_c22_s3_tid, rcu_lane_ops_c22_s2_tid, rcu_lane_ops_c22_s1_tid, rcu_lane_ops_c22_s0_tid, rcu_lane_ops_c21_s3_tid, rcu_lane_ops_c21_s2_tid, rcu_lane_ops_c21_s1_tid, rcu_lane_ops_c21_s0_tid, rcu_lane_ops_c20_s3_tid, rcu_lane_ops_c20_s2_tid, rcu_lane_ops_c20_s1_tid, rcu_lane_ops_c20_s0_tid, rcu_lane_ops_c19_s3_tid, rcu_lane_ops_c19_s2_tid, rcu_lane_ops_c19_s1_tid, rcu_lane_ops_c19_s0_tid, rcu_lane_ops_c18_s3_tid, rcu_lane_ops_c18_s2_tid, rcu_lane_ops_c18_s1_tid, rcu_lane_ops_c18_s0_tid, rcu_lane_ops_c17_s3_tid, rcu_lane_ops_c17_s2_tid, rcu_lane_ops_c17_s1_tid, rcu_lane_ops_c17_s0_tid, rcu_lane_ops_c16_s3_tid, rcu_lane_ops_c16_s2_tid, rcu_lane_ops_c16_s1_tid, rcu_lane_ops_c16_s0_tid, rcu_lane_ops_c15_s3_tid, rcu_lane_ops_c15_s2_tid, rcu_lane_ops_c15_s1_tid, rcu_lane_ops_c15_s0_tid, rcu_lane_ops_c14_s3_tid, rcu_lane_ops_c14_s2_tid, rcu_lane_ops_c14_s1_tid, rcu_lane_ops_c14_s0_tid, rcu_lane_ops_c13_s3_tid, rcu_lane_ops_c13_s2_tid, rcu_lane_ops_c13_s1_tid, rcu_lane_ops_c13_s0_tid, rcu_lane_ops_c12_s3_tid, rcu_lane_ops_c12_s2_tid, rcu_lane_ops_c12_s1_tid, rcu_lane_ops_c12_s0_tid, rcu_lane_ops_c11_s3_tid, rcu_lane_ops_c11_s2_tid, rcu_lane_ops_c11_s1_tid, rcu_lane_ops_c11_s0_tid, rcu_lane_ops_c10_s3_tid, rcu_lane_ops_c10_s2_tid, rcu_lane_ops_c10_s1_tid, rcu_lane_ops_c10_s0_tid, rcu_lane_ops_c09_s3_tid, rcu_lane_ops_c09_s2_tid, rcu_lane_ops_c09_s1_tid, rcu_lane_ops_c09_s0_tid, rcu_lane_ops_c08_s3_tid, rcu_lane_ops_c08_s2_tid, rcu_lane_ops_c08_s1_tid, rcu_lane_ops_c08_s0_tid, rcu_lane_ops_c07_s3_tid, rcu_lane_ops_c07_s2_tid, rcu_lane_ops_c07_s1_tid, rcu_lane_ops_c07_s0_tid, rcu_lane_ops_c06_s3_tid, rcu_lane_ops_c06_s2_tid, rcu_lane_ops_c06_s1_tid, rcu_lane_ops_c06_s0_tid, rcu_lane_ops_c05_s3_tid, rcu_lane_ops_c05_s2_tid, rcu_lane_ops_c05_s1_tid, rcu_lane_ops_c05_s0_tid, rcu_lane_ops_c04_s3_tid, rcu_lane_ops_c04_s2_tid, rcu_lane_ops_c04_s1_tid, rcu_lane_ops_c04_s0_tid, rcu_lane_ops_c03_s3_tid, rcu_lane_ops_c03_s2_tid, rcu_lane_ops_c03_s1_tid, rcu_lane_ops_c03_s0_tid, rcu_lane_ops_c02_s3_tid, rcu_lane_ops_c02_s2_tid, rcu_lane_ops_c02_s1_tid, rcu_lane_ops_c02_s0_tid, rcu_lane_ops_c01_s3_tid, rcu_lane_ops_c01_s2_tid, rcu_lane_ops_c01_s1_tid, rcu_lane_ops_c01_s0_tid, rcu_lane_ops_c00_s3_tid, rcu_lane_ops_c00_s2_tid, rcu_lane_ops_c00_s1_tid, rcu_lane_ops_c00_s0_tid, ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid, ooe_rcu_issue_s1_tid, ooe_rcu_issue_s0_tid, dec_ooe_uop_s5_tid, dec_ooe_uop_s4_tid, dec_ooe_uop_s3_tid, dec_ooe_uop_s2_tid, dec_ooe_uop_s1_tid, dec_ooe_uop_s0_tid, fet_dec_instr_s7_tid, fet_dec_instr_s6_tid, fet_dec_instr_s5_tid, fet_dec_instr_s4_tid, fet_dec_instr_s3_tid, fet_dec_instr_s2_tid, fet_dec_instr_s1_tid, fet_dec_instr_s0_tid})
`endif
  );
`endif

endmodule
