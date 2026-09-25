// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_ooe. Included between the parentheses of the
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
  // dec -> ooe, 6 slot(s) x 128 bit payload
  input  logic [5:0] dec_ooe_uop_valid,
  input  logic [767:0] dec_ooe_uop_payload,
  output logic [5:0] dec_ooe_uop_credit,
  output logic [5:0] dec_ooe_uop_stall,
  // ooe -> rcu, 4 slot(s) x 56 bit payload
  output logic [3:0] ooe_rcu_issue_valid,
  output logic [223:0] ooe_rcu_issue_payload,
  input  logic [3:0] ooe_rcu_issue_credit,
  input  logic [3:0] ooe_rcu_issue_stall,
  // rcu -> ooe, 4 slot(s) x 40 bit payload
  input  logic [3:0] rcu_ooe_done_valid,
  input  logic [159:0] rcu_ooe_done_payload,
  output logic [3:0] rcu_ooe_done_credit,
  output logic [3:0] rcu_ooe_done_stall,
  // ooe -> miu, 4 slot(s) x 60 bit payload
  output logic [3:0] ooe_miu_memop_valid,
  output logic [239:0] ooe_miu_memop_payload,
  input  logic [3:0] ooe_miu_memop_credit,
  input  logic [3:0] ooe_miu_memop_stall,
  // miu -> ooe, 4 slot(s) x 110 bit payload
  input  logic [3:0] miu_ooe_cmpl_valid,
  input  logic [439:0] miu_ooe_cmpl_payload,
  output logic [3:0] miu_ooe_cmpl_credit,
  output logic [3:0] miu_ooe_cmpl_stall,
  // ooe -> miu, 4 slot(s) x 8 bit payload
  output logic [3:0] ooe_miu_retire_valid,
  output logic [31:0] ooe_miu_retire_payload,
  input  logic [3:0] ooe_miu_retire_credit,
  input  logic [3:0] ooe_miu_retire_stall,
  // rau -> ooe, 1 slot(s) x 22 bit payload
  input  logic rau_ooe_alloc_valid,
  input  logic [21:0] rau_ooe_alloc_payload,
  output logic rau_ooe_alloc_credit,
  output logic rau_ooe_alloc_stall,
  // ooe -> rau, 1 slot(s) x 15 bit payload
  output logic ooe_rau_status_valid,
  output logic [14:0] ooe_rau_status_payload,
  input  logic ooe_rau_status_credit,
  input  logic ooe_rau_status_stall,
  // rau -> ooe, 1 slot(s) x 6 bit payload
  input  logic rau_ooe_demote_valid,
  input  logic [5:0] rau_ooe_demote_payload,
  output logic rau_ooe_demote_credit,
  output logic rau_ooe_demote_stall,
  // ooe -> rau, 1 slot(s) x 70 bit payload
  output logic ooe_rau_drained_valid,
  output logic [69:0] ooe_rau_drained_payload,
  input  logic ooe_rau_drained_credit,
  input  logic ooe_rau_drained_stall,
  // ooe -> syu, 1 slot(s) x 13 bit payload
  output logic ooe_syu_bar_valid,
  output logic [12:0] ooe_syu_bar_payload,
  input  logic ooe_syu_bar_credit,
  input  logic ooe_syu_bar_stall,
  // syu -> ooe, 1 slot(s) x 36 bit payload
  input  logic syu_ooe_rel_valid,
  input  logic [35:0] syu_ooe_rel_payload,
  output logic syu_ooe_rel_credit,
  output logic syu_ooe_rel_stall,
  // ooe -> cru, 1 slot(s) x 172 bit payload
  output logic ooe_cru_fault_valid,
  output logic [171:0] ooe_cru_fault_payload,
  input  logic ooe_cru_fault_credit,
  input  logic ooe_cru_fault_stall
`ifdef CCV_TRACE
  , input  logic [383:0] dec_ooe_uop_tid
  , output logic [255:0] ooe_rcu_issue_tid
  , input  logic [255:0] rcu_ooe_done_tid
  , output logic [255:0] ooe_miu_memop_tid
  , input  logic [255:0] miu_ooe_cmpl_tid
  , output logic [255:0] ooe_miu_retire_tid
  , input  logic [63:0] rau_ooe_alloc_tid
  , output logic [63:0] ooe_rau_status_tid
  , input  logic [63:0] rau_ooe_demote_tid
  , output logic [63:0] ooe_rau_drained_tid
  , output logic [63:0] ooe_syu_bar_tid
  , input  logic [63:0] syu_ooe_rel_tid
  , output logic [63:0] ooe_cru_fault_tid
`endif
