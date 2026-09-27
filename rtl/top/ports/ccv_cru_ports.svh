// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_cru. Included between the parentheses of the
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
  input  logic [48:0] csr_req,
  // csr_req of every other block instance, by instance index, cru's own omitted
  output logic [2155:0] csr_reqs,
  output logic [32:0] csr_rsp,
  // csr_rsp of every other block instance, by instance index, cru's own omitted
  input  logic [1451:0] csr_rsps,
  output logic csr_credit,
  // csr_credit of every other block instance, by instance index, cru's own omitted
  input  logic [43:0] csr_credits,
  // ooe -> cru
  input  logic ooe_cru_fault_valid,
  input  ccv_ooe_cru_fault_t ooe_cru_fault_payload,
  output logic ooe_cru_fault_credit,
  output logic ooe_cru_fault_stall,
  input  logic ooe_cru_fault_wake,
  // cru -> rau
  output logic cru_rau_cfg_valid,
  output ccv_cru_rau_cfg_t cru_rau_cfg_payload,
  input  logic cru_rau_cfg_credit,
  input  logic cru_rau_cfg_stall,
  output logic cru_rau_cfg_wake
`ifdef CCV_CHECK
  , output logic clk_gated
`endif
`ifdef CCV_TRACE
  , input  logic [63:0] ooe_cru_fault_tid
  , output logic [63:0] cru_rau_cfg_tid
`endif
