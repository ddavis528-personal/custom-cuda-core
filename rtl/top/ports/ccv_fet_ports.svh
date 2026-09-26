// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_fet. Included between the parentheses of the
// module header, in the stub and in the real RTL alike.
//
// Channel ports are named by channel, not stage-tagged: stage
// numbers are assigned at 4a, and the tag belongs on the internal
// flop that drives the port. One group per slot:
//   <chan>[_c<NN>][_s<K>]_{valid,payload,credit,stall}, and
//   <chan>[_c<NN>]_wake per channel instance; `_c` only where a
// block names one of several copies, `_s` only at rate > 1.
// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE);
// `clk_gated` is an observation for the checker bank (CCV_CHECK).
//
// One clock, core_clk, UNGATED: the block gates it as its first act,
// inside the block. The top holds only block instances and nets.
  input  logic core_clk,
  input  logic rst_n,
  input  logic kill_valid,
  input  logic [31:0] kill_warp_mask,
  input  logic [1:0] kill_epoch,
  output logic kill_ack,
  output logic [1:0] kill_ack_epoch,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // fet -> dec, slot 0 of 8
  output logic fet_dec_instr_s0_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s0_payload,
  input  logic fet_dec_instr_s0_credit,
  input  logic fet_dec_instr_s0_stall,
  // fet -> dec, slot 1 of 8
  output logic fet_dec_instr_s1_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s1_payload,
  input  logic fet_dec_instr_s1_credit,
  input  logic fet_dec_instr_s1_stall,
  // fet -> dec, slot 2 of 8
  output logic fet_dec_instr_s2_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s2_payload,
  input  logic fet_dec_instr_s2_credit,
  input  logic fet_dec_instr_s2_stall,
  // fet -> dec, slot 3 of 8
  output logic fet_dec_instr_s3_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s3_payload,
  input  logic fet_dec_instr_s3_credit,
  input  logic fet_dec_instr_s3_stall,
  // fet -> dec, slot 4 of 8
  output logic fet_dec_instr_s4_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s4_payload,
  input  logic fet_dec_instr_s4_credit,
  input  logic fet_dec_instr_s4_stall,
  // fet -> dec, slot 5 of 8
  output logic fet_dec_instr_s5_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s5_payload,
  input  logic fet_dec_instr_s5_credit,
  input  logic fet_dec_instr_s5_stall,
  // fet -> dec, slot 6 of 8
  output logic fet_dec_instr_s6_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s6_payload,
  input  logic fet_dec_instr_s6_credit,
  input  logic fet_dec_instr_s6_stall,
  // fet -> dec, slot 7 of 8
  output logic fet_dec_instr_s7_valid,
  output ccv_fet_dec_instr_t fet_dec_instr_s7_payload,
  input  logic fet_dec_instr_s7_credit,
  input  logic fet_dec_instr_s7_stall,
  output logic fet_dec_instr_wake,
  // ooe -> fet
  input  logic ooe_fet_redirect_valid,
  input  ccv_ooe_fet_redirect_t ooe_fet_redirect_payload,
  output logic ooe_fet_redirect_credit,
  output logic ooe_fet_redirect_stall,
  input  logic ooe_fet_redirect_wake,
  // fet -> mlc
  output logic fet_mlc_ifill_valid,
  output ccv_fet_mlc_ifill_t fet_mlc_ifill_payload,
  input  logic fet_mlc_ifill_credit,
  input  logic fet_mlc_ifill_stall,
  output logic fet_mlc_ifill_wake,
  // mlc -> fet
  input  logic mlc_fet_ifill_rsp_valid,
  input  ccv_mlc_fet_ifill_rsp_t mlc_fet_ifill_rsp_payload,
  output logic mlc_fet_ifill_rsp_credit,
  output logic mlc_fet_ifill_rsp_stall,
  input  logic mlc_fet_ifill_rsp_wake,
  // miu -> fet
  input  logic miu_fet_itlb_valid,
  input  ccv_miu_fet_itlb_t miu_fet_itlb_payload,
  output logic miu_fet_itlb_credit,
  output logic miu_fet_itlb_stall,
  input  logic miu_fet_itlb_wake,
  // fet -> miu
  output logic fet_miu_itlb_req_valid,
  output ccv_fet_miu_itlb_req_t fet_miu_itlb_req_payload,
  input  logic fet_miu_itlb_req_credit,
  input  logic fet_miu_itlb_req_stall,
  output logic fet_miu_itlb_req_wake,
  // rau -> fet
  input  logic rau_fet_launch_valid,
  input  ccv_rau_fet_launch_t rau_fet_launch_payload,
  output logic rau_fet_launch_credit,
  output logic rau_fet_launch_stall,
  input  logic rau_fet_launch_wake,
  // fet -> pca
  output logic fet_pca_mig_valid,
  output ccv_fet_pca_mig_t fet_pca_mig_payload,
  input  logic fet_pca_mig_credit,
  input  logic fet_pca_mig_stall,
  output logic fet_pca_mig_wake,
  // pca -> fet
  input  logic pca_fet_mig_valid,
  input  ccv_pca_fet_mig_t pca_fet_mig_payload,
  output logic pca_fet_mig_credit,
  output logic pca_fet_mig_stall,
  input  logic pca_fet_mig_wake,
  // rau -> fet
  input  logic rau_fet_mig_valid,
  input  ccv_rau_fet_mig_t rau_fet_mig_payload,
  output logic rau_fet_mig_credit,
  output logic rau_fet_mig_stall,
  input  logic rau_fet_mig_wake
`ifdef CCV_CHECK
  , output logic clk_gated
`endif
`ifdef CCV_TRACE
  , output logic [63:0] fet_dec_instr_s0_tid
  , output logic [63:0] fet_dec_instr_s1_tid
  , output logic [63:0] fet_dec_instr_s2_tid
  , output logic [63:0] fet_dec_instr_s3_tid
  , output logic [63:0] fet_dec_instr_s4_tid
  , output logic [63:0] fet_dec_instr_s5_tid
  , output logic [63:0] fet_dec_instr_s6_tid
  , output logic [63:0] fet_dec_instr_s7_tid
  , input  logic [63:0] ooe_fet_redirect_tid
  , output logic [63:0] fet_mlc_ifill_tid
  , input  logic [63:0] mlc_fet_ifill_rsp_tid
  , input  logic [63:0] miu_fet_itlb_tid
  , output logic [63:0] fet_miu_itlb_req_tid
  , input  logic [63:0] rau_fet_launch_tid
  , output logic [63:0] fet_pca_mig_tid
  , input  logic [63:0] pca_fet_mig_tid
  , input  logic [63:0] rau_fet_mig_tid
`endif
