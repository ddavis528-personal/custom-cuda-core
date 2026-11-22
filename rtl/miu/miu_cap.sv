//===-- miu_cap.sv - MIU address capture, one ccv_rcu_miu_addr slot -------===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 147): the stage table's
//       H row and the module partition's miu_cap row).
//
// One instance per address slot (4, slot k from pipe Pk). ccv_rcu_miu_addr
// is fixed-latency and MIU's end is abutted (link_n 0, bnd_rx 0): its valid
// lands in V, a cycle ahead of the payload (no lead field), so the payload
// is on the wire in V+1 and held from H = V+2, the cycle MIU's first
// registers hold both the memop and its address (A-61). Stage tags count
// from the memop's arrival M = 00 (miu_pair's), so V = M + LAG = 03 (LAG 3),
// the payload 04 and H 05.
//
// The valid is captured every cycle (v_q, CG-5: the payload's enable is this
// module's own flop, never an input) and the payload is captured under it:
// active_mask, base_per_lane and index_per_lane, 2,080 flops at the default
// sizes, one clock gate. store_data is slice 2's (the payload register file)
// and rob_tag pairs the address with its memop in miu_pair, so neither is
// held here. A fence's message carries only rob_tag and active_mask; its
// other fields are don't-care and are captured as they come.
//
// Inputs are capture flops (arrival 0: MIU's ends stay at 0 NGD, A-61,
// RI-11), and every output comes straight from a flop.
//
// The reference is the MIU model's address capture (sim/miu/miu_block.cpp,
// the addr_ map filled on ccv_rcu_miu_addr), and test/miu/cap_tb.cpp holds
// this module to a value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_cap #(
  parameter  int NL = ccv_params_pkg::CCV_W_LANE_MASK,   // lanes, 32
  parameter  int WD = ccv_params_pkg::CCV_W_DATA         // a per-lane field, NL x 32 bits
) (
  input  logic          miu_core_clk,
  input  logic          rst_n,
  // ccv_rcu_miu_addr_s<k>: the valid in V, the payload's fields in V+1.
  input  logic          av_cm03h,       // rcu_miu_addr_s<k>_valid
  input  logic [NL-1:0] am_cm04h,       // payload.active_mask
  input  logic [WD-1:0] base_cm04h,     // payload.base_per_lane
  input  logic [WD-1:0] idx_cm04h,      // payload.index_per_lane
  // The capture, held from H until the next message's.
  output logic          v_cm04h,        // the valid, a cycle on: a payload lands this cycle
  output logic [NL-1:0] am_cm05h,
  output logic [WD-1:0] base_cm05h,
  output logic [WD-1:0] idx_cm05h
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
  (* keep *) logic v_q_cm04h;
  (* keep *) logic vo_q_cm04h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      v_q_cm04h  <= 1'b0;
      vo_q_cm04h <= 1'b0;
    end else begin
      v_q_cm04h  <= av_cm03h;
      vo_q_cm04h <= av_cm03h;
    end
  end
  assign v_cm04h  = vo_q_cm04h;

  // ---- The payload, under the valid a cycle on ---------------------------
  // A guarded payload: read only through the memop that owns it, so it is
  // written whenever its group is clocked and holds nothing of its own.
  wire pay_en_cm04h = v_q_cm04h;
  logic [NL-1:0] am_q_cm05h;
  logic [WD-1:0] base_q_cm05h, idx_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (pay_en_cm04h) begin
      am_q_cm05h   <= am_cm04h;
      base_q_cm05h <= base_cm04h;
      idx_q_cm05h  <= idx_cm04h;
    end
  end
  assign am_cm05h   = am_q_cm05h;
  assign base_cm05h = base_q_cm05h;
  assign idx_cm05h  = idx_q_cm05h;

endmodule
`undef CCV_CLK
`undef CCV_RST
