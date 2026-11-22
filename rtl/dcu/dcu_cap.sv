//===-- dcu_cap.sv - DCU request capture, one ccv_miu_dcu_req slot --------===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab, "MA's Phase 2", slice 1 (rev 82): the stage table's
//       D0 and D1 rows and the module partition's dcu_cap row).
//
// One instance per request slot (4). ccv_miu_dcu_req's DCU end is abutted
// (link_n 0, bnd_rx 0), every receiving end no-flop: the valid and its lead
// field lead_set_index are on the wire in H+1 and held from D0 = H+2, when
// the bank's tag read starts; the payload is on the wire in H+2 and held
// from D1 = H+3. Stage tags count from H = 00 (the MIU tab's H).
//
// The valid and lead_set_index are captured every cycle: nothing earlier
// names a lookup, so they cannot be gated by this module's own flops (CG-5).
// They are interface lead flops, waived with "lead": true and charged to
// the block's 2% (MA's partition; Daniel's ruling on RI-15). The lookup
// payload (req_id, the line's PA, pa_fold, drop, coh_op, exclusive_req) is
// captured under the valid's flop, one clock gate. Store data and its mask
// are slice 2's.
//
// Inputs are capture flops (arrival 0: DCU's ends stay at 0 NGD), and every
// output comes straight from a flop; the valid's flop that also enables the
// payload has a (* keep *) copy for the port.
//
// pa_fold is MIU's fold of the request's PA (MA-30, AR 405). Until TI lands
// the field on ccv_miu_dcu_req, the block top ties this port from DCU's own
// fold; the unit bench drives it.
//
// The reference is the DCU model's intake (sim/dcu/dcu_block.cpp, work():
// take(c.miu_dcu, s) and decode), and test/dcu/cap_tb.cpp holds this module
// to a value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK dcu_core_clk
`define CCV_RST rst_r01h
module dcu_cap #(
  parameter  int WS = ccv_prov_pkg::CCV_W_DCU_SET,                  // lead_set_index, 9
  parameter  int WI = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU,            // req_id, 6
  parameter  int WA = ccv_prov_pkg::CCV_P_W_PA,                     // PA, 48
  parameter  int WO = $clog2(ccv_prov_pkg::CCV_P_LINE_BYTES),       // line offset, 7
  parameter  int WF = ccv_prov_pkg::CCV_DCU_WAYPRED_BITS,           // pa_fold
  parameter  int WC = ccv_prelim_pkg::CCV_L_W_COH_OP                // coh_op, 4
) (
  input  logic             dcu_core_clk,
  input  logic             rst_n,
  // ccv_miu_dcu_req_s<k>: the valid and its lead in H+1, the payload in H+2.
  input  logic             rv_cc01h,       // miu_dcu_req_s<k>_valid
  input  logic [WS-1:0]    lsi_cc01h,      // payload.lead_set_index (LEAD)
  input  logic [WI-1:0]    rid_cc02h,      // payload.req_id
  input  logic [WA-1:WO]   pa_cc02h,       // payload.phys_addr, the line's
  input  logic [WF-1:0]    fold_cc02h,     // payload.pa_fold (MA-30)
  input  logic             drop_cc02h,     // payload.drop (MA-27)
  input  logic [WC-1:0]    coh_cc02h,      // payload.coh_op
  input  logic             excl_cc02h,     // payload.exclusive_req
  // D0: the lookup's valid and set, for the bank's tag read and arbitration.
  output logic             v_cc02h,
  output logic [WS-1:0]    lsi_cc02h,
  // D1: the lookup's payload, held until the next lookup's.
  output logic [WI-1:0]    rid_cc03h,
  output logic [WA-1:WO]   pa_cc03h,
  output logic [WF-1:0]    fold_cc03h,
  output logic             drop_cc03h,
  output logic [WC-1:0]    coh_cc03h,
  output logic             excl_cc03h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge dcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The valid and its lead, captured every cycle (CG-5) ---------------
  // Two copies of the valid, each (* keep *): one is the payload's enable
  // inside, the other drives the port (a register that drives an output is
  // held on every path it starts to that output's budget, 2026-10-19).
  (* keep *) logic v_q_cc02h;
  (* keep *) logic vo_q_cc02h;
  logic [WS-1:0] lsi_q_cc02h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      v_q_cc02h  <= 1'b0;
      vo_q_cc02h <= 1'b0;
    end else begin
      v_q_cc02h  <= rv_cc01h;
      vo_q_cc02h <= rv_cc01h;
    end
  end
  // The lead is read only through the valid beside it, so it needs no reset.
  always_ff @(posedge dcu_core_clk) begin
    lsi_q_cc02h <= lsi_cc01h;
  end
  assign v_cc02h   = vo_q_cc02h;
  assign lsi_cc02h = lsi_q_cc02h;

  // ---- The payload, under the valid a cycle on ---------------------------
  // A guarded payload: read only through the lookup that owns it.
  wire pay_en_cc02h = v_q_cc02h;
  logic [WI-1:0]  rid_q_cc03h;
  logic [WA-1:WO] pa_q_cc03h;
  logic [WF-1:0]  fold_q_cc03h;
  logic           drop_q_cc03h;
  logic [WC-1:0]  coh_q_cc03h;
  logic           excl_q_cc03h;
  always_ff @(posedge dcu_core_clk) begin
    if (pay_en_cc02h) begin
      rid_q_cc03h  <= rid_cc02h;
      pa_q_cc03h   <= pa_cc02h;
      fold_q_cc03h <= fold_cc02h;
      drop_q_cc03h <= drop_cc02h;
      coh_q_cc03h  <= coh_cc02h;
      excl_q_cc03h <= excl_cc02h;
    end
  end
  assign rid_cc03h  = rid_q_cc03h;
  assign pa_cc03h   = pa_q_cc03h;
  assign fold_cc03h = fold_q_cc03h;
  assign drop_cc03h = drop_q_cc03h;
  assign coh_cc03h  = coh_q_cc03h;
  assign excl_cc03h = excl_q_cc03h;

endmodule
`undef CCV_CLK
`undef CCV_RST
