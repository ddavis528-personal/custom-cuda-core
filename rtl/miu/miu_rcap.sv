//===-- miu_rcap.sv - MIU response capture, one ccv_dcu_miu_rsp slot -------===//
//
// Spec: CCV per-block architecture specs, MIU tab, "MA's Phase 2", slice 1
//       (rev 181): the stage table's R1 and R2 rows, the module partition's
//       miu_rcap row (4, one per rsp slot, R2: read_data, hit, req_id and
//       MA-28's check bits), and Port NGD budgets (every ccv_dcu_miu_rsp
//       input at arrival 0; miu_rcap outputs out 0).
//
// One instance per response slot (CCV_DCACHE_LOOKUPS, 4). ccv_dcu_miu_rsp
// is fixed-latency and MIU's end is abutted (link_n 0, bnd_rx 0), a no-flop
// end: its valid lands a cycle ahead of the payload (no lead field), and
// MIU's own flops capture both at 0 NGD. Stage tags count from the memop's
// arrival M = 00, H = 05 (miu_cap's): the rsp valid launches at H+6 = 11
// and is held at R1 = 12, the cycle the payload is on the wire; the payload
// is held from R2 = 13.
//
// The valid is captured every cycle (CG-5: the payload's enable is this
// module's own flop, never an input), and the payload under it: req_id,
// read_data, hit, ownership_granted, mlc_miss and check_bits, 1,105 flops
// at the default sizes, one clock gate. The payload is a guarded one, read
// only through the valid a cycle on (cv), so it holds nothing of its own.
//
// Outputs: rv (R1: a response's payload lands this cycle, the lead miu_ids
// and the response side enable on) and cv (R2: the capture holds a new
// response), each from a (* keep *) copy of its flop; the payload straight
// from its flops (out 0, miu_rcap.ngd.json). The req_id leaves at out 0 to
// miu_ids's read (MI-28, MA rev 197).
//
// The reference is the MIU model's ccv_dcu_miu_rsp receive
// (sim/miu/miu_block.cpp), and test/miu/rcap_tb.cpp holds this module to a
// value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_rcap #(
  parameter  int IW = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU,         // req_id, 6
  parameter  int WD = ccv_params_pkg::CCV_W_DATA,                // read_data, 1024
  parameter  int CW = ccv_params_pkg::CCV_DCU_ECC_CHECK_W        // check_bits, 72
) (
  input  logic          miu_core_clk,
  input  logic          rst_n,
  // ccv_dcu_miu_rsp_s<j>: the valid in R1-1, the payload's fields in R1.
  input  logic          v_cm11h,        // dcu_miu_rsp_s<j>_valid
  input  logic [IW-1:0] rid_cm12h,      // payload.req_id
  input  logic [WD-1:0] rd_cm12h,       // payload.read_data
  input  logic          hit_cm12h,      // payload.hit
  input  logic          own_cm12h,      // payload.ownership_granted
  input  logic          mlc_cm12h,      // payload.mlc_miss
  input  logic [CW-1:0] cb_cm12h,       // payload.check_bits
  // The capture.
  output logic          rv_cm12h,       // R1: a payload lands this cycle
  output logic          cv_cm13h,       // R2: the capture holds a new response
  output logic [IW-1:0] rid_cm13h,
  output logic [WD-1:0] rd_cm13h,
  output logic          hit_cm13h,
  output logic          own_cm13h,
  output logic          mlc_cm13h,
  output logic [CW-1:0] cb_cm13h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The valid, captured every cycle (CG-5) ----------------------------
  // Two copies, each (* keep *): one is the payload's enable inside, the
  // other drives the port (a register that drives an output is held on
  // every path it starts to that output's budget, 2026-10-19).
  (* keep *) logic v_q_cm12h;
  (* keep *) logic vo_q_cm12h;
  logic            cv_q_cm13h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      v_q_cm12h  <= 1'b0;
      vo_q_cm12h <= 1'b0;
      cv_q_cm13h <= 1'b0;
    end else begin
      v_q_cm12h  <= v_cm11h;
      vo_q_cm12h <= v_cm11h;
      cv_q_cm13h <= v_q_cm12h;
    end
  end
  assign rv_cm12h = vo_q_cm12h;
  assign cv_cm13h = cv_q_cm13h;

  // ---- The payload, under the valid a cycle on ---------------------------
  wire pay_en_cm12h = v_q_cm12h;
  logic [IW-1:0] rid_q_cm13h;
  logic [WD-1:0] rd_q_cm13h;
  logic          hit_q_cm13h, own_q_cm13h, mlc_q_cm13h;
  logic [CW-1:0] cb_q_cm13h;
  always_ff @(posedge miu_core_clk) begin
    if (pay_en_cm12h) begin
      rid_q_cm13h <= rid_cm12h;
      rd_q_cm13h  <= rd_cm12h;
      hit_q_cm13h <= hit_cm12h;
      own_q_cm13h <= own_cm12h;
      mlc_q_cm13h <= mlc_cm12h;
      cb_q_cm13h  <= cb_cm12h;
    end
  end
  assign rid_cm13h = rid_q_cm13h;
  assign rd_cm13h  = rd_q_cm13h;
  assign hit_cm13h = hit_q_cm13h;
  assign own_cm13h = own_q_cm13h;
  assign mlc_cm13h = mlc_q_cm13h;
  assign cb_cm13h  = cb_q_cm13h;

endmodule
`undef CCV_CLK
`undef CCV_RST
