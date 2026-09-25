// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// The CCV core: 45 block instances, 104 channel instances.
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
  output logic [1224:0] exb_ext_out_payload,
  input  logic exb_ext_out_credit,
  input  logic exb_ext_out_stall,
  output logic exb_ext_out_wake,
  input  logic ext_exb_in_valid,
  input  logic [1175:0] ext_exb_in_payload,
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

  // ccv_fet_dec_instr: fet -> dec, 1 copy x 8 slot
  logic [7:0] fet_dec_instr_valid;
  logic [975:0] fet_dec_instr_payload;
  logic [7:0] fet_dec_instr_credit;
  logic [7:0] fet_dec_instr_stall;
  logic fet_dec_instr_wake;
`ifdef CCV_TRACE
  logic [511:0] fet_dec_instr_tid;
`endif
  // ccv_dec_ooe_uop: dec -> ooe, 1 copy x 6 slot
  logic [5:0] dec_ooe_uop_valid;
  logic [803:0] dec_ooe_uop_payload;
  logic [5:0] dec_ooe_uop_credit;
  logic [5:0] dec_ooe_uop_stall;
  logic dec_ooe_uop_wake;
`ifdef CCV_TRACE
  logic [383:0] dec_ooe_uop_tid;
`endif
  // ccv_ooe_rcu_issue: ooe -> rcu, 1 copy x 4 slot
  logic [3:0] ooe_rcu_issue_valid;
  logic [515:0] ooe_rcu_issue_payload;
  logic [3:0] ooe_rcu_issue_credit;
  logic [3:0] ooe_rcu_issue_stall;
  logic ooe_rcu_issue_wake;
`ifdef CCV_TRACE
  logic [255:0] ooe_rcu_issue_tid;
`endif
  // ccv_rcu_lane_ops: rcu -> lane, 32 copy x 4 slot
  logic [127:0] rcu_lane_ops_valid;
  logic [14079:0] rcu_lane_ops_payload;
  logic [127:0] rcu_lane_ops_credit;
  logic [127:0] rcu_lane_ops_stall;
  logic [31:0] rcu_lane_ops_wake;
`ifdef CCV_TRACE
  logic [8191:0] rcu_lane_ops_tid;
`endif
  // ccv_lane_rcu_res: lane -> rcu, 32 copy x 4 slot
  logic [127:0] lane_rcu_res_valid;
  logic [4223:0] lane_rcu_res_payload;
  logic [127:0] lane_rcu_res_credit;
  logic [127:0] lane_rcu_res_stall;
  logic [31:0] lane_rcu_res_wake;
`ifdef CCV_TRACE
  logic [8191:0] lane_rcu_res_tid;
`endif
  // ccv_rcu_ooe_done: rcu -> ooe, 1 copy x 4 slot
  logic [3:0] rcu_ooe_done_valid;
  logic [291:0] rcu_ooe_done_payload;
  logic [3:0] rcu_ooe_done_credit;
  logic [3:0] rcu_ooe_done_stall;
  logic rcu_ooe_done_wake;
`ifdef CCV_TRACE
  logic [255:0] rcu_ooe_done_tid;
`endif
  // ccv_rcu_miu_addr: rcu -> miu, 1 copy x 4 slot
  logic [3:0] rcu_miu_addr_valid;
  logic [8603:0] rcu_miu_addr_payload;
  logic [3:0] rcu_miu_addr_credit;
  logic [3:0] rcu_miu_addr_stall;
  logic rcu_miu_addr_wake;
`ifdef CCV_TRACE
  logic [255:0] rcu_miu_addr_tid;
`endif
  // ccv_miu_rcu_data: miu -> rcu, 1 copy x 4 slot
  logic [3:0] miu_rcu_data_valid;
  logic [4283:0] miu_rcu_data_payload;
  logic [3:0] miu_rcu_data_credit;
  logic [3:0] miu_rcu_data_stall;
  logic miu_rcu_data_wake;
`ifdef CCV_TRACE
  logic [255:0] miu_rcu_data_tid;
`endif
  // ccv_ooe_miu_memop: ooe -> miu, 1 copy x 4 slot
  logic [3:0] ooe_miu_memop_valid;
  logic [307:0] ooe_miu_memop_payload;
  logic [3:0] ooe_miu_memop_credit;
  logic [3:0] ooe_miu_memop_stall;
  logic ooe_miu_memop_wake;
`ifdef CCV_TRACE
  logic [255:0] ooe_miu_memop_tid;
`endif
  // ccv_miu_ooe_cmpl: miu -> ooe, 1 copy x 4 slot
  logic [3:0] miu_ooe_cmpl_valid;
  logic [439:0] miu_ooe_cmpl_payload;
  logic [3:0] miu_ooe_cmpl_credit;
  logic [3:0] miu_ooe_cmpl_stall;
  logic miu_ooe_cmpl_wake;
`ifdef CCV_TRACE
  logic [255:0] miu_ooe_cmpl_tid;
`endif
  // ccv_ooe_miu_retire: ooe -> miu, 1 copy x 4 slot
  logic [3:0] ooe_miu_retire_valid;
  logic [31:0] ooe_miu_retire_payload;
  logic [3:0] ooe_miu_retire_credit;
  logic [3:0] ooe_miu_retire_stall;
  logic ooe_miu_retire_wake;
`ifdef CCV_TRACE
  logic [255:0] ooe_miu_retire_tid;
`endif
  // ccv_ooe_fet_redirect: ooe -> fet, 1 copy x 1 slot
  logic ooe_fet_redirect_valid;
  logic [200:0] ooe_fet_redirect_payload;
  logic ooe_fet_redirect_credit;
  logic ooe_fet_redirect_stall;
  logic ooe_fet_redirect_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_fet_redirect_tid;
`endif
  // ccv_miu_spm_req: miu -> spm, 1 copy x 4 slot
  logic [3:0] miu_spm_req_valid;
  logic [5907:0] miu_spm_req_payload;
  logic [3:0] miu_spm_req_credit;
  logic [3:0] miu_spm_req_stall;
  logic miu_spm_req_wake;
`ifdef CCV_TRACE
  logic [255:0] miu_spm_req_tid;
`endif
  // ccv_spm_miu_rsp: spm -> miu, 1 copy x 4 slot
  logic [3:0] spm_miu_rsp_valid;
  logic [4131:0] spm_miu_rsp_payload;
  logic [3:0] spm_miu_rsp_credit;
  logic [3:0] spm_miu_rsp_stall;
  logic spm_miu_rsp_wake;
`ifdef CCV_TRACE
  logic [255:0] spm_miu_rsp_tid;
`endif
  // ccv_miu_dcu_req: miu -> dcu, 1 copy x 4 slot
  logic [3:0] miu_dcu_req_valid;
  logic [4847:0] miu_dcu_req_payload;
  logic [3:0] miu_dcu_req_credit;
  logic [3:0] miu_dcu_req_stall;
  logic miu_dcu_req_wake;
`ifdef CCV_TRACE
  logic [255:0] miu_dcu_req_tid;
`endif
  // ccv_dcu_miu_rsp: dcu -> miu, 1 copy x 4 slot
  logic [3:0] dcu_miu_rsp_valid;
  logic [4119:0] dcu_miu_rsp_payload;
  logic [3:0] dcu_miu_rsp_credit;
  logic [3:0] dcu_miu_rsp_stall;
  logic dcu_miu_rsp_wake;
`ifdef CCV_TRACE
  logic [255:0] dcu_miu_rsp_tid;
`endif
  // ccv_dcu_mlc_req: dcu -> mlc, 1 copy x 1 slot
  logic dcu_mlc_req_valid;
  logic [1081:0] dcu_mlc_req_payload;
  logic dcu_mlc_req_credit;
  logic dcu_mlc_req_stall;
  logic dcu_mlc_req_wake;
`ifdef CCV_TRACE
  logic [63:0] dcu_mlc_req_tid;
`endif
  // ccv_mlc_dcu_rsp: mlc -> dcu, 1 copy x 1 slot
  logic mlc_dcu_rsp_valid;
  logic [1029:0] mlc_dcu_rsp_payload;
  logic mlc_dcu_rsp_credit;
  logic mlc_dcu_rsp_stall;
  logic mlc_dcu_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_dcu_rsp_tid;
`endif
  // ccv_mlc_dcu_probe: mlc -> dcu, 1 copy x 1 slot
  logic mlc_dcu_probe_valid;
  logic [50:0] mlc_dcu_probe_payload;
  logic mlc_dcu_probe_credit;
  logic mlc_dcu_probe_stall;
  logic mlc_dcu_probe_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_dcu_probe_tid;
`endif
  // ccv_dcu_mlc_probe_ack: dcu -> mlc, 1 copy x 1 slot
  logic dcu_mlc_probe_ack_valid;
  logic [1026:0] dcu_mlc_probe_ack_payload;
  logic dcu_mlc_probe_ack_credit;
  logic dcu_mlc_probe_ack_stall;
  logic dcu_mlc_probe_ack_wake;
`ifdef CCV_TRACE
  logic [63:0] dcu_mlc_probe_ack_tid;
`endif
  // ccv_fet_mlc_ifill: fet -> mlc, 1 copy x 1 slot
  logic fet_mlc_ifill_valid;
  logic [57:0] fet_mlc_ifill_payload;
  logic fet_mlc_ifill_credit;
  logic fet_mlc_ifill_stall;
  logic fet_mlc_ifill_wake;
`ifdef CCV_TRACE
  logic [63:0] fet_mlc_ifill_tid;
`endif
  // ccv_mlc_fet_ifill_rsp: mlc -> fet, 1 copy x 1 slot
  logic mlc_fet_ifill_rsp_valid;
  logic [1025:0] mlc_fet_ifill_rsp_payload;
  logic mlc_fet_ifill_rsp_credit;
  logic mlc_fet_ifill_rsp_stall;
  logic mlc_fet_ifill_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_fet_ifill_rsp_tid;
`endif
  // ccv_miu_fet_itlb: miu -> fet, 1 copy x 1 slot
  logic miu_fet_itlb_valid;
  logic [63:0] miu_fet_itlb_payload;
  logic miu_fet_itlb_credit;
  logic miu_fet_itlb_stall;
  logic miu_fet_itlb_wake;
`ifdef CCV_TRACE
  logic [63:0] miu_fet_itlb_tid;
`endif
  // ccv_fet_miu_itlb_req: fet -> miu, 1 copy x 1 slot
  logic fet_miu_itlb_req_valid;
  logic [71:0] fet_miu_itlb_req_payload;
  logic fet_miu_itlb_req_credit;
  logic fet_miu_itlb_req_stall;
  logic fet_miu_itlb_req_wake;
`ifdef CCV_TRACE
  logic [63:0] fet_miu_itlb_req_tid;
`endif
  // ccv_mlc_exb_req: mlc -> exb, 1 copy x 1 slot
  logic mlc_exb_req_valid;
  logic [1089:0] mlc_exb_req_payload;
  logic mlc_exb_req_credit;
  logic mlc_exb_req_stall;
  logic mlc_exb_req_wake;
`ifdef CCV_TRACE
  logic [63:0] mlc_exb_req_tid;
`endif
  // ccv_exb_mlc_rsp: exb -> mlc, 1 copy x 1 slot
  logic exb_mlc_rsp_valid;
  logic [1081:0] exb_mlc_rsp_payload;
  logic exb_mlc_rsp_credit;
  logic exb_mlc_rsp_stall;
  logic exb_mlc_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] exb_mlc_rsp_tid;
`endif
  // ccv_rau_fet_launch: rau -> fet, 1 copy x 1 slot
  logic rau_fet_launch_valid;
  logic [183:0] rau_fet_launch_payload;
  logic rau_fet_launch_credit;
  logic rau_fet_launch_stall;
  logic rau_fet_launch_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_fet_launch_tid;
`endif
  // ccv_rau_ooe_alloc: rau -> ooe, 1 copy x 1 slot
  logic rau_ooe_alloc_valid;
  logic [21:0] rau_ooe_alloc_payload;
  logic rau_ooe_alloc_credit;
  logic rau_ooe_alloc_stall;
  logic rau_ooe_alloc_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_ooe_alloc_tid;
`endif
  // ccv_ooe_rau_status: ooe -> rau, 1 copy x 1 slot
  logic ooe_rau_status_valid;
  logic [15:0] ooe_rau_status_payload;
  logic ooe_rau_status_credit;
  logic ooe_rau_status_stall;
  logic ooe_rau_status_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_rau_status_tid;
`endif
  // ccv_rau_ooe_demote: rau -> ooe, 1 copy x 1 slot
  logic rau_ooe_demote_valid;
  logic [5:0] rau_ooe_demote_payload;
  logic rau_ooe_demote_credit;
  logic rau_ooe_demote_stall;
  logic rau_ooe_demote_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_ooe_demote_tid;
`endif
  // ccv_ooe_rau_drained: ooe -> rau, 1 copy x 1 slot
  logic ooe_rau_drained_valid;
  logic [69:0] ooe_rau_drained_payload;
  logic ooe_rau_drained_credit;
  logic ooe_rau_drained_stall;
  logic ooe_rau_drained_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_rau_drained_tid;
`endif
  // ccv_rau_rcu_mig: rau -> rcu, 1 copy x 1 slot
  logic rau_rcu_mig_valid;
  logic [8:0] rau_rcu_mig_payload;
  logic rau_rcu_mig_credit;
  logic rau_rcu_mig_stall;
  logic rau_rcu_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_rcu_mig_tid;
`endif
  // ccv_rcu_pca_mig: rcu -> pca, 1 copy x 1 slot
  logic rcu_pca_mig_valid;
  logic [2303:0] rcu_pca_mig_payload;
  logic rcu_pca_mig_credit;
  logic rcu_pca_mig_stall;
  logic rcu_pca_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] rcu_pca_mig_tid;
`endif
  // ccv_pca_rcu_mig: pca -> rcu, 1 copy x 1 slot
  logic pca_rcu_mig_valid;
  logic [2303:0] pca_rcu_mig_payload;
  logic pca_rcu_mig_credit;
  logic pca_rcu_mig_stall;
  logic pca_rcu_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] pca_rcu_mig_tid;
`endif
  // ccv_rau_miu_cta: rau -> miu, 1 copy x 1 slot
  logic rau_miu_cta_valid;
  logic [100:0] rau_miu_cta_payload;
  logic rau_miu_cta_credit;
  logic rau_miu_cta_stall;
  logic rau_miu_cta_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_miu_cta_tid;
`endif
  // ccv_ooe_syu_bar: ooe -> syu, 1 copy x 1 slot
  logic ooe_syu_bar_valid;
  logic [12:0] ooe_syu_bar_payload;
  logic ooe_syu_bar_credit;
  logic ooe_syu_bar_stall;
  logic ooe_syu_bar_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_syu_bar_tid;
`endif
  // ccv_syu_ooe_rel: syu -> ooe, 1 copy x 1 slot
  logic syu_ooe_rel_valid;
  logic [35:0] syu_ooe_rel_payload;
  logic syu_ooe_rel_credit;
  logic syu_ooe_rel_stall;
  logic syu_ooe_rel_wake;
`ifdef CCV_TRACE
  logic [63:0] syu_ooe_rel_tid;
`endif
  // ccv_rau_syu_alloc: rau -> syu, 1 copy x 1 slot
  logic rau_syu_alloc_valid;
  logic [16:0] rau_syu_alloc_payload;
  logic rau_syu_alloc_credit;
  logic rau_syu_alloc_stall;
  logic rau_syu_alloc_wake;
`ifdef CCV_TRACE
  logic [63:0] rau_syu_alloc_tid;
`endif
  // ccv_ooe_cru_fault: ooe -> cru, 1 copy x 1 slot
  logic ooe_cru_fault_valid;
  logic [171:0] ooe_cru_fault_payload;
  logic ooe_cru_fault_credit;
  logic ooe_cru_fault_stall;
  logic ooe_cru_fault_wake;
`ifdef CCV_TRACE
  logic [63:0] ooe_cru_fault_tid;
`endif
  // ccv_cru_rau_cfg: cru -> rau, 1 copy x 1 slot
  logic cru_rau_cfg_valid;
  logic [73:0] cru_rau_cfg_payload;
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
    .fet_dec_instr_valid(fet_dec_instr_valid),
    .fet_dec_instr_payload(fet_dec_instr_payload),
    .fet_dec_instr_credit(fet_dec_instr_credit),
    .fet_dec_instr_stall(fet_dec_instr_stall),
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
    .rau_fet_launch_wake(rau_fet_launch_wake)
`ifdef CCV_TRACE
    , .fet_dec_instr_tid(fet_dec_instr_tid),
      .ooe_fet_redirect_tid(ooe_fet_redirect_tid),
      .fet_mlc_ifill_tid(fet_mlc_ifill_tid),
      .mlc_fet_ifill_rsp_tid(mlc_fet_ifill_rsp_tid),
      .miu_fet_itlb_tid(miu_fet_itlb_tid),
      .fet_miu_itlb_req_tid(fet_miu_itlb_req_tid),
      .rau_fet_launch_tid(rau_fet_launch_tid)
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
    .fet_dec_instr_valid(fet_dec_instr_valid),
    .fet_dec_instr_payload(fet_dec_instr_payload),
    .fet_dec_instr_credit(fet_dec_instr_credit),
    .fet_dec_instr_stall(fet_dec_instr_stall),
    .fet_dec_instr_wake(fet_dec_instr_wake),
    .dec_ooe_uop_valid(dec_ooe_uop_valid),
    .dec_ooe_uop_payload(dec_ooe_uop_payload),
    .dec_ooe_uop_credit(dec_ooe_uop_credit),
    .dec_ooe_uop_stall(dec_ooe_uop_stall),
    .dec_ooe_uop_wake(dec_ooe_uop_wake)
`ifdef CCV_TRACE
    , .fet_dec_instr_tid(fet_dec_instr_tid),
      .dec_ooe_uop_tid(dec_ooe_uop_tid)
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
    .dec_ooe_uop_valid(dec_ooe_uop_valid),
    .dec_ooe_uop_payload(dec_ooe_uop_payload),
    .dec_ooe_uop_credit(dec_ooe_uop_credit),
    .dec_ooe_uop_stall(dec_ooe_uop_stall),
    .dec_ooe_uop_wake(dec_ooe_uop_wake),
    .ooe_rcu_issue_valid(ooe_rcu_issue_valid),
    .ooe_rcu_issue_payload(ooe_rcu_issue_payload),
    .ooe_rcu_issue_credit(ooe_rcu_issue_credit),
    .ooe_rcu_issue_stall(ooe_rcu_issue_stall),
    .ooe_rcu_issue_wake(ooe_rcu_issue_wake),
    .rcu_ooe_done_valid(rcu_ooe_done_valid),
    .rcu_ooe_done_payload(rcu_ooe_done_payload),
    .rcu_ooe_done_credit(rcu_ooe_done_credit),
    .rcu_ooe_done_stall(rcu_ooe_done_stall),
    .rcu_ooe_done_wake(rcu_ooe_done_wake),
    .ooe_miu_memop_valid(ooe_miu_memop_valid),
    .ooe_miu_memop_payload(ooe_miu_memop_payload),
    .ooe_miu_memop_credit(ooe_miu_memop_credit),
    .ooe_miu_memop_stall(ooe_miu_memop_stall),
    .ooe_miu_memop_wake(ooe_miu_memop_wake),
    .miu_ooe_cmpl_valid(miu_ooe_cmpl_valid),
    .miu_ooe_cmpl_payload(miu_ooe_cmpl_payload),
    .miu_ooe_cmpl_credit(miu_ooe_cmpl_credit),
    .miu_ooe_cmpl_stall(miu_ooe_cmpl_stall),
    .miu_ooe_cmpl_wake(miu_ooe_cmpl_wake),
    .ooe_miu_retire_valid(ooe_miu_retire_valid),
    .ooe_miu_retire_payload(ooe_miu_retire_payload),
    .ooe_miu_retire_credit(ooe_miu_retire_credit),
    .ooe_miu_retire_stall(ooe_miu_retire_stall),
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
    , .dec_ooe_uop_tid(dec_ooe_uop_tid),
      .ooe_rcu_issue_tid(ooe_rcu_issue_tid),
      .rcu_ooe_done_tid(rcu_ooe_done_tid),
      .ooe_miu_memop_tid(ooe_miu_memop_tid),
      .miu_ooe_cmpl_tid(miu_ooe_cmpl_tid),
      .ooe_miu_retire_tid(ooe_miu_retire_tid),
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
    .ooe_rcu_issue_valid(ooe_rcu_issue_valid),
    .ooe_rcu_issue_payload(ooe_rcu_issue_payload),
    .ooe_rcu_issue_credit(ooe_rcu_issue_credit),
    .ooe_rcu_issue_stall(ooe_rcu_issue_stall),
    .ooe_rcu_issue_wake(ooe_rcu_issue_wake),
    .rcu_lane_ops_valid(rcu_lane_ops_valid),
    .rcu_lane_ops_payload(rcu_lane_ops_payload),
    .rcu_lane_ops_credit(rcu_lane_ops_credit),
    .rcu_lane_ops_stall(rcu_lane_ops_stall),
    .rcu_lane_ops_wake(rcu_lane_ops_wake),
    .lane_rcu_res_valid(lane_rcu_res_valid),
    .lane_rcu_res_payload(lane_rcu_res_payload),
    .lane_rcu_res_credit(lane_rcu_res_credit),
    .lane_rcu_res_stall(lane_rcu_res_stall),
    .lane_rcu_res_wake(lane_rcu_res_wake),
    .rcu_ooe_done_valid(rcu_ooe_done_valid),
    .rcu_ooe_done_payload(rcu_ooe_done_payload),
    .rcu_ooe_done_credit(rcu_ooe_done_credit),
    .rcu_ooe_done_stall(rcu_ooe_done_stall),
    .rcu_ooe_done_wake(rcu_ooe_done_wake),
    .rcu_miu_addr_valid(rcu_miu_addr_valid),
    .rcu_miu_addr_payload(rcu_miu_addr_payload),
    .rcu_miu_addr_credit(rcu_miu_addr_credit),
    .rcu_miu_addr_stall(rcu_miu_addr_stall),
    .rcu_miu_addr_wake(rcu_miu_addr_wake),
    .miu_rcu_data_valid(miu_rcu_data_valid),
    .miu_rcu_data_payload(miu_rcu_data_payload),
    .miu_rcu_data_credit(miu_rcu_data_credit),
    .miu_rcu_data_stall(miu_rcu_data_stall),
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
    , .ooe_rcu_issue_tid(ooe_rcu_issue_tid),
      .rcu_lane_ops_tid(rcu_lane_ops_tid),
      .lane_rcu_res_tid(lane_rcu_res_tid),
      .rcu_ooe_done_tid(rcu_ooe_done_tid),
      .rcu_miu_addr_tid(rcu_miu_addr_tid),
      .miu_rcu_data_tid(miu_rcu_data_tid),
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[0 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[0 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[0 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[0 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[0]),
    .lane_rcu_res_valid(lane_rcu_res_valid[0 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[0 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[0 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[0 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[0])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[0 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[0 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[4 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[440 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[4 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[4 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[1]),
    .lane_rcu_res_valid(lane_rcu_res_valid[4 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[132 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[4 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[4 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[1])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[256 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[256 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[8 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[880 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[8 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[8 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[2]),
    .lane_rcu_res_valid(lane_rcu_res_valid[8 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[264 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[8 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[8 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[2])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[512 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[512 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[12 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[1320 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[12 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[12 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[3]),
    .lane_rcu_res_valid(lane_rcu_res_valid[12 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[396 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[12 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[12 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[3])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[768 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[768 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[16 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[1760 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[16 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[16 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[4]),
    .lane_rcu_res_valid(lane_rcu_res_valid[16 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[528 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[16 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[16 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[4])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[1024 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[1024 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[20 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[2200 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[20 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[20 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[5]),
    .lane_rcu_res_valid(lane_rcu_res_valid[20 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[660 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[20 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[20 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[5])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[1280 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[1280 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[24 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[2640 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[24 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[24 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[6]),
    .lane_rcu_res_valid(lane_rcu_res_valid[24 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[792 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[24 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[24 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[6])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[1536 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[1536 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[28 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[3080 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[28 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[28 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[7]),
    .lane_rcu_res_valid(lane_rcu_res_valid[28 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[924 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[28 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[28 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[7])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[1792 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[1792 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[32 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[3520 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[32 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[32 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[8]),
    .lane_rcu_res_valid(lane_rcu_res_valid[32 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1056 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[32 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[32 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[8])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[2048 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[2048 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[36 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[3960 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[36 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[36 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[9]),
    .lane_rcu_res_valid(lane_rcu_res_valid[36 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1188 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[36 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[36 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[9])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[2304 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[2304 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[40 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[4400 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[40 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[40 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[10]),
    .lane_rcu_res_valid(lane_rcu_res_valid[40 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1320 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[40 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[40 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[10])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[2560 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[2560 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[44 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[4840 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[44 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[44 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[11]),
    .lane_rcu_res_valid(lane_rcu_res_valid[44 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1452 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[44 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[44 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[11])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[2816 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[2816 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[48 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[5280 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[48 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[48 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[12]),
    .lane_rcu_res_valid(lane_rcu_res_valid[48 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1584 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[48 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[48 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[12])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[3072 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[3072 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[52 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[5720 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[52 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[52 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[13]),
    .lane_rcu_res_valid(lane_rcu_res_valid[52 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1716 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[52 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[52 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[13])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[3328 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[3328 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[56 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[6160 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[56 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[56 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[14]),
    .lane_rcu_res_valid(lane_rcu_res_valid[56 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1848 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[56 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[56 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[14])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[3584 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[3584 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[60 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[6600 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[60 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[60 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[15]),
    .lane_rcu_res_valid(lane_rcu_res_valid[60 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[1980 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[60 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[60 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[15])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[3840 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[3840 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[64 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[7040 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[64 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[64 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[16]),
    .lane_rcu_res_valid(lane_rcu_res_valid[64 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[2112 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[64 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[64 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[16])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[4096 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[4096 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[68 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[7480 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[68 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[68 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[17]),
    .lane_rcu_res_valid(lane_rcu_res_valid[68 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[2244 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[68 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[68 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[17])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[4352 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[4352 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[72 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[7920 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[72 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[72 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[18]),
    .lane_rcu_res_valid(lane_rcu_res_valid[72 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[2376 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[72 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[72 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[18])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[4608 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[4608 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[76 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[8360 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[76 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[76 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[19]),
    .lane_rcu_res_valid(lane_rcu_res_valid[76 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[2508 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[76 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[76 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[19])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[4864 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[4864 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[80 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[8800 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[80 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[80 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[20]),
    .lane_rcu_res_valid(lane_rcu_res_valid[80 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[2640 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[80 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[80 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[20])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[5120 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[5120 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[84 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[9240 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[84 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[84 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[21]),
    .lane_rcu_res_valid(lane_rcu_res_valid[84 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[2772 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[84 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[84 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[21])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[5376 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[5376 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[88 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[9680 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[88 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[88 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[22]),
    .lane_rcu_res_valid(lane_rcu_res_valid[88 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[2904 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[88 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[88 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[22])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[5632 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[5632 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[92 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[10120 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[92 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[92 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[23]),
    .lane_rcu_res_valid(lane_rcu_res_valid[92 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3036 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[92 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[92 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[23])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[5888 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[5888 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[96 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[10560 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[96 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[96 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[24]),
    .lane_rcu_res_valid(lane_rcu_res_valid[96 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3168 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[96 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[96 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[24])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[6144 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[6144 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[100 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[11000 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[100 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[100 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[25]),
    .lane_rcu_res_valid(lane_rcu_res_valid[100 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3300 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[100 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[100 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[25])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[6400 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[6400 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[104 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[11440 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[104 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[104 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[26]),
    .lane_rcu_res_valid(lane_rcu_res_valid[104 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3432 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[104 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[104 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[26])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[6656 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[6656 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[108 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[11880 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[108 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[108 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[27]),
    .lane_rcu_res_valid(lane_rcu_res_valid[108 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3564 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[108 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[108 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[27])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[6912 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[6912 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[112 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[12320 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[112 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[112 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[28]),
    .lane_rcu_res_valid(lane_rcu_res_valid[112 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3696 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[112 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[112 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[28])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[7168 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[7168 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[116 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[12760 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[116 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[116 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[29]),
    .lane_rcu_res_valid(lane_rcu_res_valid[116 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3828 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[116 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[116 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[29])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[7424 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[7424 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[120 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[13200 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[120 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[120 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[30]),
    .lane_rcu_res_valid(lane_rcu_res_valid[120 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[3960 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[120 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[120 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[30])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[7680 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[7680 +: 256])
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
    .rcu_lane_ops_valid(rcu_lane_ops_valid[124 +: 4]),
    .rcu_lane_ops_payload(rcu_lane_ops_payload[13640 +: 440]),
    .rcu_lane_ops_credit(rcu_lane_ops_credit[124 +: 4]),
    .rcu_lane_ops_stall(rcu_lane_ops_stall[124 +: 4]),
    .rcu_lane_ops_wake(rcu_lane_ops_wake[31]),
    .lane_rcu_res_valid(lane_rcu_res_valid[124 +: 4]),
    .lane_rcu_res_payload(lane_rcu_res_payload[4092 +: 132]),
    .lane_rcu_res_credit(lane_rcu_res_credit[124 +: 4]),
    .lane_rcu_res_stall(lane_rcu_res_stall[124 +: 4]),
    .lane_rcu_res_wake(lane_rcu_res_wake[31])
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(rcu_lane_ops_tid[7936 +: 256]),
      .lane_rcu_res_tid(lane_rcu_res_tid[7936 +: 256])
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
    .rcu_miu_addr_valid(rcu_miu_addr_valid),
    .rcu_miu_addr_payload(rcu_miu_addr_payload),
    .rcu_miu_addr_credit(rcu_miu_addr_credit),
    .rcu_miu_addr_stall(rcu_miu_addr_stall),
    .rcu_miu_addr_wake(rcu_miu_addr_wake),
    .miu_rcu_data_valid(miu_rcu_data_valid),
    .miu_rcu_data_payload(miu_rcu_data_payload),
    .miu_rcu_data_credit(miu_rcu_data_credit),
    .miu_rcu_data_stall(miu_rcu_data_stall),
    .miu_rcu_data_wake(miu_rcu_data_wake),
    .ooe_miu_memop_valid(ooe_miu_memop_valid),
    .ooe_miu_memop_payload(ooe_miu_memop_payload),
    .ooe_miu_memop_credit(ooe_miu_memop_credit),
    .ooe_miu_memop_stall(ooe_miu_memop_stall),
    .ooe_miu_memop_wake(ooe_miu_memop_wake),
    .miu_ooe_cmpl_valid(miu_ooe_cmpl_valid),
    .miu_ooe_cmpl_payload(miu_ooe_cmpl_payload),
    .miu_ooe_cmpl_credit(miu_ooe_cmpl_credit),
    .miu_ooe_cmpl_stall(miu_ooe_cmpl_stall),
    .miu_ooe_cmpl_wake(miu_ooe_cmpl_wake),
    .ooe_miu_retire_valid(ooe_miu_retire_valid),
    .ooe_miu_retire_payload(ooe_miu_retire_payload),
    .ooe_miu_retire_credit(ooe_miu_retire_credit),
    .ooe_miu_retire_stall(ooe_miu_retire_stall),
    .ooe_miu_retire_wake(ooe_miu_retire_wake),
    .miu_spm_req_valid(miu_spm_req_valid),
    .miu_spm_req_payload(miu_spm_req_payload),
    .miu_spm_req_credit(miu_spm_req_credit),
    .miu_spm_req_stall(miu_spm_req_stall),
    .miu_spm_req_wake(miu_spm_req_wake),
    .spm_miu_rsp_valid(spm_miu_rsp_valid),
    .spm_miu_rsp_payload(spm_miu_rsp_payload),
    .spm_miu_rsp_credit(spm_miu_rsp_credit),
    .spm_miu_rsp_stall(spm_miu_rsp_stall),
    .spm_miu_rsp_wake(spm_miu_rsp_wake),
    .miu_dcu_req_valid(miu_dcu_req_valid),
    .miu_dcu_req_payload(miu_dcu_req_payload),
    .miu_dcu_req_credit(miu_dcu_req_credit),
    .miu_dcu_req_stall(miu_dcu_req_stall),
    .miu_dcu_req_wake(miu_dcu_req_wake),
    .dcu_miu_rsp_valid(dcu_miu_rsp_valid),
    .dcu_miu_rsp_payload(dcu_miu_rsp_payload),
    .dcu_miu_rsp_credit(dcu_miu_rsp_credit),
    .dcu_miu_rsp_stall(dcu_miu_rsp_stall),
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
    , .rcu_miu_addr_tid(rcu_miu_addr_tid),
      .miu_rcu_data_tid(miu_rcu_data_tid),
      .ooe_miu_memop_tid(ooe_miu_memop_tid),
      .miu_ooe_cmpl_tid(miu_ooe_cmpl_tid),
      .ooe_miu_retire_tid(ooe_miu_retire_tid),
      .miu_spm_req_tid(miu_spm_req_tid),
      .spm_miu_rsp_tid(spm_miu_rsp_tid),
      .miu_dcu_req_tid(miu_dcu_req_tid),
      .dcu_miu_rsp_tid(dcu_miu_rsp_tid),
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
    .miu_spm_req_valid(miu_spm_req_valid),
    .miu_spm_req_payload(miu_spm_req_payload),
    .miu_spm_req_credit(miu_spm_req_credit),
    .miu_spm_req_stall(miu_spm_req_stall),
    .miu_spm_req_wake(miu_spm_req_wake),
    .spm_miu_rsp_valid(spm_miu_rsp_valid),
    .spm_miu_rsp_payload(spm_miu_rsp_payload),
    .spm_miu_rsp_credit(spm_miu_rsp_credit),
    .spm_miu_rsp_stall(spm_miu_rsp_stall),
    .spm_miu_rsp_wake(spm_miu_rsp_wake)
`ifdef CCV_TRACE
    , .miu_spm_req_tid(miu_spm_req_tid),
      .spm_miu_rsp_tid(spm_miu_rsp_tid)
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
    .miu_dcu_req_valid(miu_dcu_req_valid),
    .miu_dcu_req_payload(miu_dcu_req_payload),
    .miu_dcu_req_credit(miu_dcu_req_credit),
    .miu_dcu_req_stall(miu_dcu_req_stall),
    .miu_dcu_req_wake(miu_dcu_req_wake),
    .dcu_miu_rsp_valid(dcu_miu_rsp_valid),
    .dcu_miu_rsp_payload(dcu_miu_rsp_payload),
    .dcu_miu_rsp_credit(dcu_miu_rsp_credit),
    .dcu_miu_rsp_stall(dcu_miu_rsp_stall),
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
    , .miu_dcu_req_tid(miu_dcu_req_tid),
      .dcu_miu_rsp_tid(dcu_miu_rsp_tid),
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
    .pca_rcu_mig_wake(pca_rcu_mig_wake)
`ifdef CCV_TRACE
    , .rcu_pca_mig_tid(rcu_pca_mig_tid),
      .pca_rcu_mig_tid(pca_rcu_mig_tid)
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
    .valid({ext_exb_in_valid, cru_rau_cfg_valid, ooe_cru_fault_valid, rau_syu_alloc_valid, syu_ooe_rel_valid, ooe_syu_bar_valid, rau_miu_cta_valid, pca_rcu_mig_valid, rcu_pca_mig_valid, rau_rcu_mig_valid, ooe_rau_drained_valid, rau_ooe_demote_valid, ooe_rau_status_valid, rau_ooe_alloc_valid, rau_fet_launch_valid, exb_ext_out_valid, exb_mlc_rsp_valid, mlc_exb_req_valid, fet_miu_itlb_req_valid, miu_fet_itlb_valid, mlc_fet_ifill_rsp_valid, fet_mlc_ifill_valid, dcu_mlc_probe_ack_valid, mlc_dcu_probe_valid, mlc_dcu_rsp_valid, dcu_mlc_req_valid, dcu_miu_rsp_valid, miu_dcu_req_valid, spm_miu_rsp_valid, miu_spm_req_valid, ooe_fet_redirect_valid, ooe_miu_retire_valid, miu_ooe_cmpl_valid, ooe_miu_memop_valid, miu_rcu_data_valid, rcu_miu_addr_valid, rcu_ooe_done_valid, lane_rcu_res_valid, rcu_lane_ops_valid, ooe_rcu_issue_valid, dec_ooe_uop_valid, fet_dec_instr_valid}),
    .credit({ext_exb_in_credit, cru_rau_cfg_credit, ooe_cru_fault_credit, rau_syu_alloc_credit, syu_ooe_rel_credit, ooe_syu_bar_credit, rau_miu_cta_credit, pca_rcu_mig_credit, rcu_pca_mig_credit, rau_rcu_mig_credit, ooe_rau_drained_credit, rau_ooe_demote_credit, ooe_rau_status_credit, rau_ooe_alloc_credit, rau_fet_launch_credit, exb_ext_out_credit, exb_mlc_rsp_credit, mlc_exb_req_credit, fet_miu_itlb_req_credit, miu_fet_itlb_credit, mlc_fet_ifill_rsp_credit, fet_mlc_ifill_credit, dcu_mlc_probe_ack_credit, mlc_dcu_probe_credit, mlc_dcu_rsp_credit, dcu_mlc_req_credit, dcu_miu_rsp_credit, miu_dcu_req_credit, spm_miu_rsp_credit, miu_spm_req_credit, ooe_fet_redirect_credit, ooe_miu_retire_credit, miu_ooe_cmpl_credit, ooe_miu_memop_credit, miu_rcu_data_credit, rcu_miu_addr_credit, rcu_ooe_done_credit, lane_rcu_res_credit, rcu_lane_ops_credit, ooe_rcu_issue_credit, dec_ooe_uop_credit, fet_dec_instr_credit}),
    .stall({ext_exb_in_stall, cru_rau_cfg_stall, ooe_cru_fault_stall, rau_syu_alloc_stall, syu_ooe_rel_stall, ooe_syu_bar_stall, rau_miu_cta_stall, pca_rcu_mig_stall, rcu_pca_mig_stall, rau_rcu_mig_stall, ooe_rau_drained_stall, rau_ooe_demote_stall, ooe_rau_status_stall, rau_ooe_alloc_stall, rau_fet_launch_stall, exb_ext_out_stall, exb_mlc_rsp_stall, mlc_exb_req_stall, fet_miu_itlb_req_stall, miu_fet_itlb_stall, mlc_fet_ifill_rsp_stall, fet_mlc_ifill_stall, dcu_mlc_probe_ack_stall, mlc_dcu_probe_stall, mlc_dcu_rsp_stall, dcu_mlc_req_stall, dcu_miu_rsp_stall, miu_dcu_req_stall, spm_miu_rsp_stall, miu_spm_req_stall, ooe_fet_redirect_stall, ooe_miu_retire_stall, miu_ooe_cmpl_stall, ooe_miu_memop_stall, miu_rcu_data_stall, rcu_miu_addr_stall, rcu_ooe_done_stall, lane_rcu_res_stall, rcu_lane_ops_stall, ooe_rcu_issue_stall, dec_ooe_uop_stall, fet_dec_instr_stall}),
    .payload({ext_exb_in_payload, cru_rau_cfg_payload, ooe_cru_fault_payload, rau_syu_alloc_payload, syu_ooe_rel_payload, ooe_syu_bar_payload, rau_miu_cta_payload, pca_rcu_mig_payload, rcu_pca_mig_payload, rau_rcu_mig_payload, ooe_rau_drained_payload, rau_ooe_demote_payload, ooe_rau_status_payload, rau_ooe_alloc_payload, rau_fet_launch_payload, exb_ext_out_payload, exb_mlc_rsp_payload, mlc_exb_req_payload, fet_miu_itlb_req_payload, miu_fet_itlb_payload, mlc_fet_ifill_rsp_payload, fet_mlc_ifill_payload, dcu_mlc_probe_ack_payload, mlc_dcu_probe_payload, mlc_dcu_rsp_payload, dcu_mlc_req_payload, dcu_miu_rsp_payload, miu_dcu_req_payload, spm_miu_rsp_payload, miu_spm_req_payload, ooe_fet_redirect_payload, ooe_miu_retire_payload, miu_ooe_cmpl_payload, ooe_miu_memop_payload, miu_rcu_data_payload, rcu_miu_addr_payload, rcu_ooe_done_payload, lane_rcu_res_payload, rcu_lane_ops_payload, ooe_rcu_issue_payload, dec_ooe_uop_payload, fet_dec_instr_payload})
`ifdef CCV_TRACE
    , .tid({ext_exb_in_tid, cru_rau_cfg_tid, ooe_cru_fault_tid, rau_syu_alloc_tid, syu_ooe_rel_tid, ooe_syu_bar_tid, rau_miu_cta_tid, pca_rcu_mig_tid, rcu_pca_mig_tid, rau_rcu_mig_tid, ooe_rau_drained_tid, rau_ooe_demote_tid, ooe_rau_status_tid, rau_ooe_alloc_tid, rau_fet_launch_tid, exb_ext_out_tid, exb_mlc_rsp_tid, mlc_exb_req_tid, fet_miu_itlb_req_tid, miu_fet_itlb_tid, mlc_fet_ifill_rsp_tid, fet_mlc_ifill_tid, dcu_mlc_probe_ack_tid, mlc_dcu_probe_tid, mlc_dcu_rsp_tid, dcu_mlc_req_tid, dcu_miu_rsp_tid, miu_dcu_req_tid, spm_miu_rsp_tid, miu_spm_req_tid, ooe_fet_redirect_tid, ooe_miu_retire_tid, miu_ooe_cmpl_tid, ooe_miu_memop_tid, miu_rcu_data_tid, rcu_miu_addr_tid, rcu_ooe_done_tid, lane_rcu_res_tid, rcu_lane_ops_tid, ooe_rcu_issue_tid, dec_ooe_uop_tid, fet_dec_instr_tid})
`endif
  );
`endif

endmodule
