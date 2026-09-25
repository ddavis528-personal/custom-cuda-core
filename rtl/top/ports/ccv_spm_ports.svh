// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_spm. Included between the parentheses of the
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
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // miu -> spm, 4 slot(s) x 1477 bit payload
  input  logic [3:0] miu_spm_req_valid,
  input  logic [5907:0] miu_spm_req_payload,
  output logic [3:0] miu_spm_req_credit,
  output logic [3:0] miu_spm_req_stall,
  input  logic miu_spm_req_wake,
  // spm -> miu, 4 slot(s) x 1033 bit payload
  output logic [3:0] spm_miu_rsp_valid,
  output logic [4131:0] spm_miu_rsp_payload,
  input  logic [3:0] spm_miu_rsp_credit,
  input  logic [3:0] spm_miu_rsp_stall,
  output logic spm_miu_rsp_wake
`ifdef CCV_TRACE
  , input  logic [255:0] miu_spm_req_tid
  , output logic [255:0] spm_miu_rsp_tid
`endif
