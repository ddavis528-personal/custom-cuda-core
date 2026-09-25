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
// flop that drives the port. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  // csr_req of every block instance, by instance index
  output logic [2204:0] csr_reqs,
  output logic [32:0] csr_rsp,
  // csr_rsp of every block instance, by instance index
  input  logic [1484:0] csr_rsps,
  output logic csr_credit,
  // csr_credit of every block instance, by instance index
  input  logic [44:0] csr_credits,
  // ooe -> cru, 1 slot(s) x 172 bit payload
  input  logic ooe_cru_fault_valid,
  input  logic [171:0] ooe_cru_fault_payload,
  output logic ooe_cru_fault_credit,
  output logic ooe_cru_fault_stall,
  input  logic ooe_cru_fault_wake,
  // cru -> rau, 1 slot(s) x 74 bit payload
  output logic cru_rau_cfg_valid,
  output logic [73:0] cru_rau_cfg_payload,
  input  logic cru_rau_cfg_credit,
  input  logic cru_rau_cfg_stall,
  output logic cru_rau_cfg_wake
`ifdef CCV_TRACE
  , input  logic [63:0] ooe_cru_fault_tid
  , output logic [63:0] cru_rau_cfg_tid
`endif
