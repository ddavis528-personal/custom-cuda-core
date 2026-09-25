// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_miu. Included between the parentheses of the
// module header, in the stub and in the real RTL alike.
//
// Channel ports are named by channel, not stage-tagged: stage
// numbers are assigned at 4a, and the tag belongs on the internal
// flop that drives the port. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  input  logic kill_valid,
  input  logic [3:0] kill_warp_mask,
  output logic kill_ack,
  input  logic wake_req,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // rcu -> miu, 4 slot(s) x 2151 bit payload
  input  logic [3:0] rcu_miu_addr_valid,
  input  logic [8603:0] rcu_miu_addr_payload,
  output logic [3:0] rcu_miu_addr_credit,
  output logic [3:0] rcu_miu_addr_stall,
  // miu -> rcu, 4 slot(s) x 1071 bit payload
  output logic [3:0] miu_rcu_data_valid,
  output logic [4283:0] miu_rcu_data_payload,
  input  logic [3:0] miu_rcu_data_credit,
  input  logic [3:0] miu_rcu_data_stall,
  // ooe -> miu, 4 slot(s) x 60 bit payload
  input  logic [3:0] ooe_miu_memop_valid,
  input  logic [239:0] ooe_miu_memop_payload,
  output logic [3:0] ooe_miu_memop_credit,
  output logic [3:0] ooe_miu_memop_stall,
  // miu -> ooe, 4 slot(s) x 110 bit payload
  output logic [3:0] miu_ooe_cmpl_valid,
  output logic [439:0] miu_ooe_cmpl_payload,
  input  logic [3:0] miu_ooe_cmpl_credit,
  input  logic [3:0] miu_ooe_cmpl_stall,
  // ooe -> miu, 4 slot(s) x 8 bit payload
  input  logic [3:0] ooe_miu_retire_valid,
  input  logic [31:0] ooe_miu_retire_payload,
  output logic [3:0] ooe_miu_retire_credit,
  output logic [3:0] ooe_miu_retire_stall,
  // miu -> spm, 4 slot(s) x 1477 bit payload
  output logic [3:0] miu_spm_req_valid,
  output logic [5907:0] miu_spm_req_payload,
  input  logic [3:0] miu_spm_req_credit,
  input  logic [3:0] miu_spm_req_stall,
  // spm -> miu, 4 slot(s) x 1033 bit payload
  input  logic [3:0] spm_miu_rsp_valid,
  input  logic [4131:0] spm_miu_rsp_payload,
  output logic [3:0] spm_miu_rsp_credit,
  output logic [3:0] spm_miu_rsp_stall,
  // miu -> dcu, 4 slot(s) x 1212 bit payload
  output logic [3:0] miu_dcu_req_valid,
  output logic [4847:0] miu_dcu_req_payload,
  input  logic [3:0] miu_dcu_req_credit,
  input  logic [3:0] miu_dcu_req_stall,
  // dcu -> miu, 4 slot(s) x 1030 bit payload
  input  logic [3:0] dcu_miu_rsp_valid,
  input  logic [4119:0] dcu_miu_rsp_payload,
  output logic [3:0] dcu_miu_rsp_credit,
  output logic [3:0] dcu_miu_rsp_stall,
  // miu -> fet, 1 slot(s) x 64 bit payload
  output logic miu_fet_itlb_valid,
  output logic [63:0] miu_fet_itlb_payload,
  input  logic miu_fet_itlb_credit,
  input  logic miu_fet_itlb_stall,
  // fet -> miu, 1 slot(s) x 72 bit payload
  input  logic fet_miu_itlb_req_valid,
  input  logic [71:0] fet_miu_itlb_req_payload,
  output logic fet_miu_itlb_req_credit,
  output logic fet_miu_itlb_req_stall,
  // rau -> miu, 1 slot(s) x 101 bit payload
  input  logic rau_miu_cta_valid,
  input  logic [100:0] rau_miu_cta_payload,
  output logic rau_miu_cta_credit,
  output logic rau_miu_cta_stall
`ifdef CCV_TRACE
  , input  logic [255:0] rcu_miu_addr_tid
  , output logic [255:0] miu_rcu_data_tid
  , input  logic [255:0] ooe_miu_memop_tid
  , output logic [255:0] miu_ooe_cmpl_tid
  , input  logic [255:0] ooe_miu_retire_tid
  , output logic [255:0] miu_spm_req_tid
  , input  logic [255:0] spm_miu_rsp_tid
  , output logic [255:0] miu_dcu_req_tid
  , input  logic [255:0] dcu_miu_rsp_tid
  , output logic [63:0] miu_fet_itlb_tid
  , input  logic [63:0] fet_miu_itlb_req_tid
  , input  logic [63:0] rau_miu_cta_tid
`endif
