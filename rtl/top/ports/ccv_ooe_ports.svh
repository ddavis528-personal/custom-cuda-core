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
  input  logic [31:0] kill_warp_mask,
  input  logic [1:0] kill_epoch,
  output logic kill_ack,
  output logic [1:0] kill_ack_epoch,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // dec -> ooe, 6 slot(s) x 134 bit payload
  input  logic [5:0] dec_ooe_uop_valid,
  input  logic [803:0] dec_ooe_uop_payload,
  output logic [5:0] dec_ooe_uop_credit,
  output logic [5:0] dec_ooe_uop_stall,
  input  logic dec_ooe_uop_wake,
  // ooe -> rcu, 4 slot(s) x 129 bit payload
  output logic [3:0] ooe_rcu_issue_valid,
  output logic [515:0] ooe_rcu_issue_payload,
  input  logic [3:0] ooe_rcu_issue_credit,
  input  logic [3:0] ooe_rcu_issue_stall,
  output logic ooe_rcu_issue_wake,
  // rcu -> ooe, 4 slot(s) x 73 bit payload
  input  logic [3:0] rcu_ooe_done_valid,
  input  logic [291:0] rcu_ooe_done_payload,
  output logic [3:0] rcu_ooe_done_credit,
  output logic [3:0] rcu_ooe_done_stall,
  input  logic rcu_ooe_done_wake,
  // ooe -> miu, 4 slot(s) x 77 bit payload
  output logic [3:0] ooe_miu_memop_valid,
  output logic [307:0] ooe_miu_memop_payload,
  input  logic [3:0] ooe_miu_memop_credit,
  input  logic [3:0] ooe_miu_memop_stall,
  output logic ooe_miu_memop_wake,
  // miu -> ooe, 4 slot(s) x 110 bit payload
  input  logic [3:0] miu_ooe_cmpl_valid,
  input  logic [439:0] miu_ooe_cmpl_payload,
  output logic [3:0] miu_ooe_cmpl_credit,
  output logic [3:0] miu_ooe_cmpl_stall,
  input  logic miu_ooe_cmpl_wake,
  // ooe -> miu, 4 slot(s) x 8 bit payload
  output logic [3:0] ooe_miu_retire_valid,
  output logic [31:0] ooe_miu_retire_payload,
  input  logic [3:0] ooe_miu_retire_credit,
  input  logic [3:0] ooe_miu_retire_stall,
  output logic ooe_miu_retire_wake,
  // ooe -> fet, 1 slot(s) x 201 bit payload
  output logic ooe_fet_redirect_valid,
  output logic [200:0] ooe_fet_redirect_payload,
  input  logic ooe_fet_redirect_credit,
  input  logic ooe_fet_redirect_stall,
  output logic ooe_fet_redirect_wake,
  // rau -> ooe, 1 slot(s) x 22 bit payload
  input  logic rau_ooe_alloc_valid,
  input  logic [21:0] rau_ooe_alloc_payload,
  output logic rau_ooe_alloc_credit,
  output logic rau_ooe_alloc_stall,
  input  logic rau_ooe_alloc_wake,
  // ooe -> rau, 1 slot(s) x 16 bit payload
  output logic ooe_rau_status_valid,
  output logic [15:0] ooe_rau_status_payload,
  input  logic ooe_rau_status_credit,
  input  logic ooe_rau_status_stall,
  output logic ooe_rau_status_wake,
  // rau -> ooe, 1 slot(s) x 6 bit payload
  input  logic rau_ooe_demote_valid,
  input  logic [5:0] rau_ooe_demote_payload,
  output logic rau_ooe_demote_credit,
  output logic rau_ooe_demote_stall,
  input  logic rau_ooe_demote_wake,
  // ooe -> rau, 1 slot(s) x 70 bit payload
  output logic ooe_rau_drained_valid,
  output logic [69:0] ooe_rau_drained_payload,
  input  logic ooe_rau_drained_credit,
  input  logic ooe_rau_drained_stall,
  output logic ooe_rau_drained_wake,
  // ooe -> syu, 1 slot(s) x 13 bit payload
  output logic ooe_syu_bar_valid,
  output logic [12:0] ooe_syu_bar_payload,
  input  logic ooe_syu_bar_credit,
  input  logic ooe_syu_bar_stall,
  output logic ooe_syu_bar_wake,
  // syu -> ooe, 1 slot(s) x 36 bit payload
  input  logic syu_ooe_rel_valid,
  input  logic [35:0] syu_ooe_rel_payload,
  output logic syu_ooe_rel_credit,
  output logic syu_ooe_rel_stall,
  input  logic syu_ooe_rel_wake,
  // ooe -> cru, 1 slot(s) x 172 bit payload
  output logic ooe_cru_fault_valid,
  output logic [171:0] ooe_cru_fault_payload,
  input  logic ooe_cru_fault_credit,
  input  logic ooe_cru_fault_stall,
  output logic ooe_cru_fault_wake
`ifdef CCV_TRACE
  , input  logic [383:0] dec_ooe_uop_tid
  , output logic [255:0] ooe_rcu_issue_tid
  , input  logic [255:0] rcu_ooe_done_tid
  , output logic [255:0] ooe_miu_memop_tid
  , input  logic [255:0] miu_ooe_cmpl_tid
  , output logic [255:0] ooe_miu_retire_tid
  , output logic [63:0] ooe_fet_redirect_tid
  , input  logic [63:0] rau_ooe_alloc_tid
  , output logic [63:0] ooe_rau_status_tid
  , input  logic [63:0] rau_ooe_demote_tid
  , output logic [63:0] ooe_rau_drained_tid
  , output logic [63:0] ooe_syu_bar_tid
  , input  logic [63:0] syu_ooe_rel_tid
  , output logic [63:0] ooe_cru_fault_tid
`endif
