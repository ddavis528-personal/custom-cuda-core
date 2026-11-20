//===-- ooe_ratmap.sv - OOE's map to RCU and the parked layout -----------===//
//
// Spec: OA 435 (8) (the register's OA tab): ccv_ooe_rcu_map from the
//       committed maps, and TI-25's parked layout (AR's rev 112): per
//       warp_id, each GPR's position and committed width, 64 bits a warp,
//       written at the demotion's map and read at restore-allocate.
//       schema/interfaces.json, ccv_ooe_rcu_map: rate 1, one whole map a
//       message; rows, positions and widths (OI-29); a demotion map may name
//       the zero registers, whose position is then 0.
//
// Requests, per tier-1 slot, a pulse each:
//   - mq: a demotion's map (ooe_slot's map verdict, direction 0);
//   - rq: a restore-allocate's map (rename, direction 1), raised the cycle
//     the committed maps hold every restore write (ooe_rat writes them two
//     edges after rename's go, OI-83 (b)).
// A slot holds one pending map at most: a second needs RAU to free and
// place the warp again. Requests queue per slot, oldest first, one map a
// cycle: a waiting request is older than an arriving one, and among
// requests arriving together a demotion's is older than a restore's, then
// the lower slot. That is the model's order (Core::control's maps, held a
// cycle by its verdict lag, then rename's restore map; the adapter queues
// them on the rate-1 channel in that order).
//
// The pick is registered (mv, its valid, ms the slot, md the direction);
// the payload is read from the picked slot's committed maps (crat, cprat:
// ooe_rat's crat_cq02h), its committed widths (ooe_rename's width table)
// and its warp at the next edge, a cycle after the valid. Nothing writes a
// slot's committed maps or widths while its map waits: a demoting slot
// retires nothing, a restoring one has renamed nothing yet, and its
// release follows its drained (asserted).
//
// The parked layout: 32 warps x 16 x (position 2 + width 2) bits, 2 Kb,
// below CCV_MACRO_RF_MIN_BYTES, so flops, each warp's 64 behind its own
// enable. A demotion's map writes it a cycle after its payload, from this
// module's own register of the payload's position and width fields (the
// zero register's position 0). A restore-allocate reads it through a
// registered port: prl, a restore-allocate, with its warp prw, both
// flopped here (the read's mux is too deep for an input's budget); pk_* a
// cycle on.
//
// Reset line (decision 6): the queue's valids, the pick's valid and the
// parked write's valid reset; the payload, the parked layout and the read
// register are payload, read only through a valid. The reset is flopped
// (RST-1). Local clock gating (docs/rtl-coding-style.md): the channel's
// payload is one gate on mv, the parked write's register one on mv and a
// demotion, each warp's parked entry one, the read register one on prl;
// the queue's and the pick's flops are outside any gate, within the
// module's allowance.
//
// The reference is the model's maps (Core::out.maps) as the adapter queues
// them, and its parked layout (Core::parkedPos/parkedWidth):
// test/ooe/ratmap_tb.cpp.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_ratmap #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int GW = 10,                 // GPR name: row and position
  parameter int PB = 2,                  // its position bits (CCV_W_PHYS_POS)
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  parameter int WB = 2,                  // a committed width's code (CCV_W_CHWIDTH)
  parameter int LW = 5,                  // warp_id (CCV_W_WARP_ID)
  localparam int NG = 16,
  localparam int NP = 4,
  localparam int NW = 1 << LW,           // warp_ids
  localparam int RW = GW - PB,           // a row
  localparam int MW = NG * GW + NP * PW, // one slot's maps, GPRs then predicates (ooe_rat's)
  localparam int KW = NG * (PB + WB)     // a parked entry
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // Map requests, a pulse per slot.
  input  logic [S-1:0]      mq_cq02h,          // a demotion's (direction 0)
  input  logic [S-1:0]      rq_cq02h,          // a restore-allocate's (direction 1)
  // Each slot's warp, committed maps and committed widths.
  input  logic [S*LW-1:0]   sw_cq02h,
  input  logic [S*MW-1:0]   crat_cq02h,
  input  logic [S*NG*WB-1:0] cw_cq02h,
  // ccv_ooe_rcu_map: the valid a cycle ahead of its payload.
  output logic              map_v_cq03h,
  output logic [LW-1:0]     map_warp_cq04h,
  output logic              map_dir_cq04h,
  output logic [NG*RW-1:0]  map_gpr_cq04h,
  output logic [NG*PB-1:0]  map_pos_cq04h,
  output logic [NG*WB-1:0]  map_w_cq04h,
  output logic [NP*PW-1:0]  map_pred_cq04h,
  // The parked layout's read: a restore-allocate and its warp.
  input  logic              prl_cq00h,
  input  logic [LW-1:0]     prw_cq00h,
  output logic [NG*PB-1:0]  pk_pos_cq02h,
  output logic [NG*WB-1:0]  pk_w_cq02h
`ifdef CCV_CHECK_RATMAP
  ,
  // Read only by the bench (test/ooe/ratmap_tb.cpp): its view of the
  // parked layout, and the control restore-first, which makes a restore's
  // request older than a demotion's arriving with it.
  input  logic              ctl_rfirst,
  input  logic [LW-1:0]     dbg_w,
  output logic [KW-1:0]     dbg_pk
`endif
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(mq_known, mq_cq02h)
  `CCV_ASSERT_KNOWN(rq_known, rq_cq02h)
  `CCV_ASSERT_KNOWN(prl_known, prl_cq00h)

  // -- the queue ---------------------------------------------------------------
  // pv: slot i's map waits; pd: its direction; ag[i * S + j]: i's request is
  // older than j's (both waiting).
  logic [S-1:0]   pv_cq02h, pd_cq02h, nw_cq02h, cand_cq02h, pick_cq02h, pv_nx_cq02h, pd_nx_cq02h;
  logic [S*S-1:0] ag_cq02h, ag_nx_cq02h;
  assign nw_cq02h = mq_cq02h | rq_cq02h;
  // i older than j among the candidates.
  logic rf;
`ifdef CCV_CHECK_RATMAP
  assign rf = ctl_rfirst;
`else
  assign rf = 1'b0;
`endif
  function automatic logic older(input logic [S-1:0] w, input logic [S-1:0] r, input logic f,
                                 input logic [S*S-1:0] ag, input int i, input int j);
    if (w[i] && w[j])      older = ag[i * S + j];
    else if (w[i] != w[j]) older = w[i];
    else if (r[i] != r[j]) older = f ? r[i] : r[j];  // arriving together: a demotion first
    else                   older = i < j;
  endfunction
  always_comb begin
    cand_cq02h = pv_cq02h | nw_cq02h;
    for (int i = 0; i < S; i++) begin
      pick_cq02h[i] = cand_cq02h[i];
      for (int j = 0; j < S; j++)
        if (j != i && cand_cq02h[j] && !older(pv_cq02h, rq_cq02h, rf, ag_cq02h, i, j)) pick_cq02h[i] = 1'b0;
      for (int j = 0; j < S; j++) ag_nx_cq02h[i * S + j] = (j != i) && older(pv_cq02h, rq_cq02h, rf, ag_cq02h, i, j);
    end
    pv_nx_cq02h = cand_cq02h & ~pick_cq02h;
    pd_nx_cq02h = (pd_cq02h & pv_cq02h) | rq_cq02h;
  end
  `CCV_ASSERT(one_pending, (pv_cq02h & nw_cq02h) == '0 && (mq_cq02h & rq_cq02h) == '0)
  `CCV_ASSERT(pick_one_hot, $onehot0(pick_cq02h) && ((cand_cq02h == '0) == (pick_cq02h == '0)))

  (* keep *) logic         mv_cq03h;           // the channel's valid
  (* keep *) logic         map_en_cq03h;           // its copy: the payload's enable
  logic [S-1:0] ms_cq03h;
  logic         md_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      pv_cq02h <= '0;
      ag_cq02h <= '0;
      mv_cq03h <= 1'b0;
      map_en_cq03h <= 1'b0;
    end else begin
      pv_cq02h <= pv_nx_cq02h;
      ag_cq02h <= ag_nx_cq02h;
      mv_cq03h <= |pick_cq02h;
      map_en_cq03h <= |pick_cq02h;
    end
  end
  // The direction of each waiting slot, and the pick's slot and direction:
  // read only through a valid.
  always_ff @(posedge ooe_core_clk) begin
    pd_cq02h <= pd_nx_cq02h;
    ms_cq03h <= pick_cq02h;
    md_cq03h <= |(pick_cq02h & pd_nx_cq02h);
  end
  assign map_v_cq03h = mv_cq03h;

  // -- the payload -----------------------------------------------------------
  logic [LW-1:0]    sel_w_cq03h;
  logic [MW-1:0]    sel_m_cq03h;
  logic [NG*WB-1:0] sel_cw_cq03h;
  always_comb begin
    sel_w_cq03h  = '0;
    sel_m_cq03h  = '0;
    sel_cw_cq03h = '0;
    for (int t = 0; t < S; t++)
      if (ms_cq03h[t]) begin
        sel_w_cq03h  = sel_w_cq03h  | sw_cq02h[t * LW +: LW];
        sel_m_cq03h  = sel_m_cq03h  | crat_cq02h[t * MW +: MW];
        sel_cw_cq03h = sel_cw_cq03h | cw_cq02h[t * NG * WB +: NG * WB];
      end
  end
  // A register's position, 0 for the zero register (whose row is all ones).
  logic [NG*PB-1:0] sel_pos_cq03h;
  logic [NG*RW-1:0] sel_row_cq03h;
  always_comb begin
    for (int a = 0; a < NG; a++) begin
      sel_row_cq03h[a * RW +: RW] = sel_m_cq03h[a * GW + PB +: RW];
      sel_pos_cq03h[a * PB +: PB] = &sel_m_cq03h[a * GW + PB +: RW] ? '0 : sel_m_cq03h[a * GW +: PB];
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (map_en_cq03h) begin
      map_warp_cq04h <= sel_w_cq03h;
      map_dir_cq04h  <= md_cq03h;
      map_gpr_cq04h  <= sel_row_cq03h;
      map_pos_cq04h  <= sel_pos_cq03h;
      map_w_cq04h    <= sel_cw_cq03h;
      map_pred_cq04h <= sel_m_cq03h[NG * GW +: NP * PW];
    end
  end

  // -- the parked layout -----------------------------------------------------
  // This module's own register of a demotion's map: the warp and each
  // register's position and width, a write at the next edge.
  logic          kv_cq04h;
  logic          kw_en_cq03h;
  logic [LW-1:0] kw_w_cq04h;
  logic [KW-1:0] kw_d_cq04h;
  logic [KW-1:0] kd_cq03h;
  assign kw_en_cq03h = map_en_cq03h && !md_cq03h;
  always_comb
    for (int a = 0; a < NG; a++)
      kd_cq03h[a * (PB + WB) +: PB + WB] = {sel_cw_cq03h[a * WB +: WB], sel_pos_cq03h[a * PB +: PB]};
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) kv_cq04h <= 1'b0;
    else          kv_cq04h <= kw_en_cq03h;
  end
  always_ff @(posedge ooe_core_clk) begin
    if (kw_en_cq03h) begin
      kw_w_cq04h <= sel_w_cq03h;
      kw_d_cq04h <= kd_cq03h;
    end
  end
  logic [KW-1:0] pk_q[NW];
  for (genvar w = 0; w < NW; w++) begin : g_pk
    logic pk_en_cq04h;
    assign pk_en_cq04h = kv_cq04h && kw_w_cq04h == LW'(w);
    always_ff @(posedge ooe_core_clk) begin
      if (pk_en_cq04h) pk_q[w] <= kw_d_cq04h;
    end
  end
  // The read: prl's flop the enable, prw's the address.
  logic          pkr_en_cq01h;
  logic [LW-1:0] prw_cq01h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) pkr_en_cq01h <= 1'b0;
    else          pkr_en_cq01h <= prl_cq00h;
  end
  always_ff @(posedge ooe_core_clk) begin
    prw_cq01h <= prw_cq00h;                // read only with prl
  end
  logic [KW-1:0] rd_cq01h;
  assign rd_cq01h = pk_q[prw_cq01h];
  always_ff @(posedge ooe_core_clk) begin
    if (pkr_en_cq01h)
      for (int a = 0; a < NG; a++) begin
        pk_pos_cq02h[a * PB +: PB] <= rd_cq01h[a * (PB + WB) +: PB];
        pk_w_cq02h[a * WB +: WB]   <= rd_cq01h[a * (PB + WB) + PB +: WB];
      end
  end
  // A restore reads its warp long after its demotion wrote it.
  `CCV_ASSERT(read_not_written, !(pkr_en_cq01h && kv_cq04h && kw_w_cq04h == prw_cq01h))
`ifdef CCV_CHECK_RATMAP
  assign dbg_pk = pk_q[dbg_w];
`endif

endmodule
`undef CCV_CLK
`undef CCV_RST
